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
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
      {text: t("layouts.sidebars.application.header"), link: root_path}
    ]
  end
end
