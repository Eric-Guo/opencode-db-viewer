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

  def timeline_categories(record, kind)
    return "events" unless kind.zero?
    return "conversation" unless record.respond_to?(:tools)

    (["conversation"] + record.tools.values.flat_map { |tool| ["tools", tool.category, *tool.calls.map(&:category)] }).uniq.join(" ")
  end
end
