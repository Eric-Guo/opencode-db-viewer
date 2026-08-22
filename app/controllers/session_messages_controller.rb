class SessionMessagesController < ApplicationController
  include DataUrlDownload

  after_action :verify_authorized, only: %i[show]

  # Serves a file item stored as a data URL inside session message content
  # (e.g. a PDF returned by a tool call) as a regular file download.
  def show
    project = policy_scope(Project).find(params[:project_id])
    session = Session.where(project_id: project.worktree_project_ids).find(params[:session_id])
    authorize session, :show?

    message = session.session_messages.find(params[:id])
    item, tool_state = find_file_item(message)
    raise ActiveRecord::RecordNotFound unless item

    mime, payload = decode_data_url(item["uri"].presence || item["url"].to_s)
    raise ActiveRecord::RecordNotFound unless payload

    send_data payload,
      filename: download_filename(message, item, tool_state, mime),
      type: mime,
      disposition: :attachment
  end

  private

  def find_file_item(message)
    content_item = message.content[params[:content].to_i]
    return unless content_item.is_a?(Hash)

    if params[:item].present? && content_item["type"] == "tool"
      state = content_item["state"]
      state = {} unless state.is_a?(Hash)
      state_content = state["content"]
      item = state_content.is_a?(Array) ? state_content[params[:item].to_i] : nil
      [item, state] if item.is_a?(Hash) && item["type"] == "file"
    elsif content_item["type"] == "file"
      [content_item, nil]
    end
  end

  def download_filename(message, item, tool_state, mime)
    input = (tool_state.is_a?(Hash) && tool_state["input"].is_a?(Hash)) ? tool_state["input"] : {}
    item["filename"].presence ||
      File.basename(input["filePath"].to_s).presence ||
      "message-#{message.id}#{Rack::Mime::MIME_TYPES.invert[mime] || ".bin"}"
  end
end
