class SessionMediaController < ApplicationController
  after_action :verify_authorized

  def show
    project = policy_scope(Project).find(params[:project_id])
    session = Session.where(project_id: project.worktree_project_ids).find(params[:session_id])
    authorize session, :show?

    ref = session.blob_refs.find_by!(hash: params[:id], message_id: params[:message_id])
    blob = ref.stored_blob
    raise ActiveRecord::RecordNotFound unless blob

    message = session.session_messages.includes(:session_parts).find_by(id: ref.message_id) ||
      session.retained_session_messages.find_by(id: ref.message_id)
    payload = message ? message.parsed_data.merge("content" => message.content) : session.session_inboxes.find_by(id: ref.message_id)&.parsed_payload
    files = Array(payload&.dig("files")) + Array(payload&.dig("content")).flat_map { |part|
      (part["type"] == "tool") ? Array(part.dig("state", "content")) : [part]
    }
    file = files.find { |item| item["uri"] == "media:#{blob.content_hash}" } || {}

    send_data blob.data,
      filename: file["name"].presence || file["filename"].presence || "#{blob.content_hash}#{Rack::Mime::MIME_TYPES.invert[blob.mime]}",
      type: blob.mime,
      disposition: (params[:preview] == "1" && blob.previewable?) ? :inline : :attachment
  end
end
