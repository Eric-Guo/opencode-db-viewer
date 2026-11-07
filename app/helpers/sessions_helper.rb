module SessionsHelper
  def session_state_badge(session)
    state = session.display_state
    color = case state
    when "succeeded" then "success"
    when "failed" then "danger"
    when "execution_claimed", "interrupted" then "warning text-dark"
    when "compacting" then "info"
    else "secondary"
    end
    content_tag(:span, t("viewer.states.#{state}"), class: "badge bg-#{color}")
  end

  def tool_state_badge(status)
    color = case status
    when "completed" then "success"
    when "error" then "danger"
    else "warning text-dark"
    end
    content_tag(:span, t("viewer.tool_states.#{status}", default: status.presence || "—"), class: "badge bg-#{color}")
  end

  def related_session_link(id, label: nil)
    session = @related_sessions[id]
    return content_tag(:code, id) unless session

    link_to(label || session.title.presence || session.slug,
      project_session_path(session.project_id, session), class: "text-break")
  end

  def attachment_info(file, message, selector)
    uri = file["uri"].presence || file["url"]
    name = file["name"].presence || file["filename"].presence || t("sessions.show.file")
    if uri.to_s.start_with?("media:")
      hash = uri.delete_prefix("media:")
      blob = @blobs[hash]
      ref = @blob_refs.find { |item| item.message_id == message.id && item.content_hash == hash }
      return {name: name, mime: file["mime"], missing: true} unless blob && ref

      url = project_session_medium_path(@project, @session, hash, message_id: message.id)
      return {name: name, mime: blob.mime, bytes: blob.bytes, width: blob.width, height: blob.height,
              url: url, preview: ("#{url}&preview=1" if blob.previewable?)}
    end
    inline = uri.to_s.start_with?("data:") || file["data"].present?
    preview = if StoredBlob::RASTER_TYPES.include?(file["mime"])
      file["data"].present? ? "data:#{file["mime"]};base64,#{file["data"]}" : uri
    end
    {name: name, mime: file["mime"], preview: preview,
     url: (project_session_message_path(@project, @session, message.id, **selector) if inline)}
  end

  def timeline_categories(record, kind)
    return "events" unless kind.zero?
    return "conversation" unless record.respond_to?(:tools)

    (["conversation"] + record.tools.values.flat_map { |tool| ["tools", tool.category, *tool.calls.map(&:category)] }).uniq.join(" ")
  end
end
