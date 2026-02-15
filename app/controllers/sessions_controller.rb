class SessionsController < ApplicationController
  after_action :verify_authorized, only: %i[show]
  before_action :set_breadcrumbs, if: -> { request.format.html? }

  def show
    @project = policy_scope(Project).find(params[:project_id])
    @session = @project.sessions.find(params[:id])
    authorize @session

    add_to_breadcrumbs t("projects.index.title"), projects_path
    add_to_breadcrumbs @project.name.presence || @project.id, project_path(@project)
    add_to_breadcrumbs @session.title.presence || @session.slug

    @messages = @session.messages
      .includes(:parts)
      .order(:time_created, :id)

    # Group into turns: each user message + its assistant replies
    @turns = build_turns(@messages)
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
      {text: t("layouts.sidebars.application.header"),
       link: root_path}
    ]
  end

  def build_turns(messages)
    turns = []
    turn_by_message_id = {}
    pending_assistants = Hash.new { |hash, key| hash[key] = [] }

    messages.each do |msg|
      if msg.user?
        turn = {user: msg, assistants: []}
        turns << turn
        turn_by_message_id[msg.id] = turn
        attach_pending_assistants!(
          turn: turn,
          parent_id: msg.id,
          pending_assistants: pending_assistants,
          turn_by_message_id: turn_by_message_id
        )
      elsif msg.assistant?
        parent_id = msg.parent_id_ref
        if parent_id.present? && turn_by_message_id.key?(parent_id)
          turn = turn_by_message_id[parent_id]
          turn[:assistants] << msg
          turn_by_message_id[msg.id] = turn
          attach_pending_assistants!(
            turn: turn,
            parent_id: msg.id,
            pending_assistants: pending_assistants,
            turn_by_message_id: turn_by_message_id
          )
        elsif parent_id.present?
          pending_assistants[parent_id] << msg
        elsif turns.last
          turns.last[:assistants] << msg
          turn_by_message_id[msg.id] = turns.last
          attach_pending_assistants!(
            turn: turns.last,
            parent_id: msg.id,
            pending_assistants: pending_assistants,
            turn_by_message_id: turn_by_message_id
          )
        else
          turn = {user: nil, assistants: [msg]}
          turns << turn
          turn_by_message_id[msg.id] = turn
          attach_pending_assistants!(
            turn: turn,
            parent_id: msg.id,
            pending_assistants: pending_assistants,
            turn_by_message_id: turn_by_message_id
          )
        end
      end
    end

    turns.concat(build_orphan_turns(pending_assistants: pending_assistants))
    sort_turns_chronologically(turns)
  end

  def attach_pending_assistants!(turn:, parent_id:, pending_assistants:, turn_by_message_id:)
    return if pending_assistants.blank?

    queue = [parent_id]

    until queue.empty?
      message_id = queue.shift
      assistants = pending_assistants.delete(message_id)
      next if assistants.blank?

      assistants.each do |assistant|
        turn[:assistants] << assistant
        turn_by_message_id[assistant.id] = turn
        queue << assistant.id
      end
    end
  end

  def build_orphan_turns(pending_assistants:)
    return [] if pending_assistants.blank?

    pending_by_parent_id = pending_assistants.to_h { |parent_id, assistants| [parent_id, assistants.dup] }
    assistant_ids = {}
    pending_by_parent_id.each_value do |assistants|
      assistants.each { |assistant| assistant_ids[assistant.id] = true }
    end

    root_parent_ids = pending_by_parent_id.keys.reject { |parent_id| assistant_ids[parent_id] }
    ordered_parent_ids = root_parent_ids + (pending_by_parent_id.keys - root_parent_ids)
    orphan_turns = []
    placed_assistant_ids = {}

    ordered_parent_ids.each do |parent_id|
      assistants = pending_by_parent_id.delete(parent_id)
      next if assistants.blank?

      turn = {user: nil, assistants: []}
      orphan_turns << turn
      attach_orphan_assistants!(
        turn: turn,
        assistants: assistants,
        pending_by_parent_id: pending_by_parent_id,
        placed_assistant_ids: placed_assistant_ids
      )
    end

    orphan_turns
  end

  def attach_orphan_assistants!(turn:, assistants:, pending_by_parent_id:, placed_assistant_ids:)
    queue = assistants.sort_by { |assistant| message_sort_key(assistant) }

    until queue.empty?
      assistant = queue.shift
      next if placed_assistant_ids[assistant.id]

      turn[:assistants] << assistant
      placed_assistant_ids[assistant.id] = true
      children = pending_by_parent_id.delete(assistant.id)
      next if children.blank?

      queue.concat(children.sort_by { |child| message_sort_key(child) })
    end
  end

  def sort_turns_chronologically(turns)
    turns.each do |turn|
      turn[:assistants] = turn[:assistants]
        .uniq { |assistant| assistant.id }
        .sort_by { |assistant| message_sort_key(assistant) }
    end

    turns.sort_by { |turn| turn_sort_key(turn) }
  end

  def turn_sort_key(turn)
    messages = [turn[:user], *turn[:assistants]].compact
    return [Float::INFINITY, ""] if messages.empty?

    messages.map { |message| message_sort_key(message) }.min
  end

  def message_sort_key(message)
    timestamp = message.time_created
    [timestamp.nil? ? Float::INFINITY : timestamp.to_i, message.id.to_s]
  end
end
