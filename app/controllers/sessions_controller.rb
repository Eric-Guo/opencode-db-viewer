class SessionsController < ApplicationController
  after_action :verify_authorized, only: :show
  before_action :set_breadcrumbs, if: -> { request.format.html? }

  def show
    @project = policy_scope(Project).find(params[:project_id])
    @session = @project.sessions.find(params[:id])
    authorize @session

    add_to_breadcrumbs t("projects.index.title"), projects_path
    add_to_breadcrumbs @project.name.presence || @project.id, project_path(@project)
    add_to_breadcrumbs @session.title.presence || @session.slug

    @session_messages = @session.session_messages.order(:seq)
    @legacy_messages = @session.messages.includes(:parts).order(:time_created, :id)
    @message_storage = @session_messages.exists? ? :session_message : :legacy
    @messages = (@message_storage == :session_message) ? @session_messages : @legacy_messages
    @pending_messages = @session.session_pendings.order(:admitted_seq)
    @instruction_entries = @session.instruction_entries.order(:key)
    events_scope = OpenCodeEvent.where(aggregate_id: @session.id)
    @event_count = events_scope.count
    @events = events_scope.order(seq: :desc).limit(100).to_a.reverse

    # Merge messages and durable events into one chronological dialog timeline.
    # kind: 0 = message, 1 = event (messages sort first on exact ties).
    message_entries = @messages.map { |message| [message.time_created_at, 0, message] }
    event_entries = @events.map { |event| [event.created_at_time, 1, event] }
    @timeline = collapse_part_event_runs(
      (message_entries + event_entries).sort_by { |time, kind, _record| [time || Time.zone.at(0), kind] }
    )

    # Tool lifecycle events only carry callID; map them back to tool names.
    @tool_call_names = {}
    @events.each do |event|
      next unless event.event_type.to_s.start_with?("session.tool.input.started")

      data = event.parsed_data
      @tool_call_names[data["callID"]] = data["name"] if data.is_a?(Hash) && data["callID"].present?
    end
  end

  private

  # Streaming writes one event per part update. Collapse each run of consecutive
  # message.part.updated events into one row per part id (latest event kept,
  # plus a collapsed count as the entry's 4th element; nil for other entries).
  def collapse_part_event_runs(entries)
    collapsed = []
    entries.chunk { |entry| entry[1] == 1 && entry[2].event_type.to_s.start_with?("message.part.updated") }.each do |part_run, chunk|
      if part_run
        chunk.group_by { |(_time, _kind, event)| part_update_key(event) }.each_value do |group|
          time, _kind, event = group.last
          collapsed << [time, 1, event, group.size]
        end
      else
        chunk.each { |entry| collapsed << (entry + [nil]) }
      end
    end
    collapsed
  end

  def part_update_key(event)
    data = event.parsed_data
    part = (data.is_a?(Hash) && data["part"].is_a?(Hash)) ? data["part"] : {}
    part["id"].presence || event.id
  end

  def set_breadcrumbs
    @_breadcrumbs = [
      {text: t("layouts.sidebars.application.header"), link: root_path}
    ]
  end
end
