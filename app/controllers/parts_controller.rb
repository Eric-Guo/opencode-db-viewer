class PartsController < ApplicationController
  after_action :verify_authorized, only: %i[show]

  # Serves a legacy part attachment stored as a data URL (e.g. a PDF captured
  # by a tool call) as a regular file download.
  def show
    project = policy_scope(Project).find(params[:project_id])
    session = project.legacy_sessions.find(params[:session_id])
    authorize session, :show?

    part = session.parts.find(params[:id])
    attachment = find_attachment(part)
    raise ActiveRecord::RecordNotFound unless attachment

    mime, payload = decode_data_url(attachment["url"].to_s)
    raise ActiveRecord::RecordNotFound unless payload

    send_data payload,
      filename: part.attachment_filename(attachment),
      type: mime,
      disposition: :attachment
  end

  private

  def find_attachment(part)
    if part.file?
      part.parsed_data if part.file_url.to_s.start_with?("data:")
    elsif part.tool?
      part.tool_attachments[params[:attachment].to_i]
    end
  end

  def decode_data_url(url)
    match = %r{\Adata:([^;,]+)?(;base64)?,(.*)\z}m.match(url)
    return [nil, nil] unless match

    [match[1].presence || "application/octet-stream", match[2] ? Base64.decode64(match[3]) : match[3]]
  end
end
