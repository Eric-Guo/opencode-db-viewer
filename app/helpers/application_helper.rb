module ApplicationHelper
  include Pagy::Frontend

  def svg_icon(cil_name, icon_class, options = {})
    options["xlink:href"] = asset_path(cil_name)
    content_tag :svg, nil, class: icon_class do
      content_tag :use, nil, options
    end
  end

  def pretty_json(value)
    JSON.pretty_generate(value)
  rescue JSON::GeneratorError, TypeError
    value.to_s
  end

  def formatted_debug_value(value)
    parsed = if value.is_a?(String)
      JSON.parse(value)
    else
      value
    end

    parsed.is_a?(String) ? parsed : pretty_json(parsed)
  rescue JSON::ParserError, TypeError
    value.to_s
  end

  def opencode_time(value)
    return "-" unless value

    value.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  # Compact label for a durable event type: drops the version suffix and the
  # first namespace segment when there are more than two ("session.tool.called.1"
  # => "tool.called", "message.updated.1" => "message.updated").
  def durable_event_type(event)
    parts = event.event_type.to_s.sub(/\.\d+\z/, "").split(".")
    (parts.length > 2) ? parts.last(2).join(".") : parts.join(".")
  end

  # "msg_f607bd8a2001ikcEBQCqkPjJBq" => "msg_…PjJBq"
  def short_opencode_id(id)
    id = id.to_s
    (id.length > 12) ? "#{id.first(4)}…#{id.last(4)}" : id
  end

  # One-line, payload-derived summary for a durable event marker row.
  def durable_event_summary(event)
    data = event.parsed_data
    return "" unless data.is_a?(Hash)

    info = data["info"].is_a?(Hash) ? data["info"] : {}
    case event.event_type.to_s.sub(/\.\d+\z/, "")
    when "session.created"
      info["directory"].to_s
    when "session.updated"
      tokens = info["tokens"].is_a?(Hash) ? info["tokens"] : {}
      cache = tokens["cache"].is_a?(Hash) ? tokens["cache"] : {}
      "tokens ↑#{number_with_delimiter(tokens["input"])} ↓#{number_with_delimiter(tokens["output"])} · cache #{number_with_delimiter(cache["read"])}"
    when "session.model.selected"
      model = data["model"].is_a?(Hash) ? data["model"] : {}
      [model["providerID"], model["id"]].compact.join("/")
    when "session.agent.selected"
      "agent #{data["agent"]}"
    when "session.input.admitted"
      input = data["input"].is_a?(Hash) ? data["input"] : {}
      [short_opencode_id(data["inputID"]), input.dig("data", "text").to_s.squish.truncate(50)].reject(&:blank?).join(" · ")
    when "session.input.promoted"
      short_opencode_id(data["inputID"])
    when "session.instructions.updated"
      delta = data["delta"].is_a?(Hash) ? data["delta"] : {}
      delta.keys.join(", ")
    when "session.step.started"
      model = data["model"].is_a?(Hash) ? data["model"] : {}
      ["agent #{data["agent"]}", [model["providerID"], model["id"]].compact.join("/")].reject(&:blank?).join(" · ")
    when "session.step.ended"
      tokens = data["tokens"].is_a?(Hash) ? data["tokens"] : {}
      [data["finish"], "↑#{number_with_delimiter(tokens["input"])} ↓#{number_with_delimiter(tokens["output"])}"].reject(&:blank?).join(" · ")
    when "session.reasoning.started", "session.text.started"
      short_opencode_id(data["assistantMessageID"])
    when "session.reasoning.ended", "session.text.ended"
      data["text"].to_s.squish.truncate(70)
    when "session.tool.input.started"
      data["name"].to_s
    when "session.tool.input.ended"
      data["text"].to_s.squish.truncate(70)
    when "session.tool.called"
      name = data["name"].presence || @tool_call_names&.[](data["callID"])
      [name, data["input"].to_json.truncate(60)].compact.reject(&:blank?).join(" ")
    when "session.tool.success"
      (data["name"].presence || @tool_call_names&.[](data["callID"])).to_s
    when "session.tool.failed"
      name = data["name"].presence || @tool_call_names&.[](data["callID"])
      [name, data.dig("error", "message").to_s.squish.truncate(60)].compact.reject(&:blank?).join(" · ")
    when "session.renamed"
      "→ #{data["title"]}"
    when "message.updated"
      model = info["model"].is_a?(Hash) ? info["model"] : {}
      [info["role"], short_opencode_id(info["id"]), [model["providerID"], model["modelID"]].compact.join("/")].compact.reject(&:blank?).join(" · ")
    when "message.part.updated"
      part = data["part"].is_a?(Hash) ? data["part"] : {}
      snippet = part["text"].presence || part["tool"].presence || part.dig("state", "status").presence
      [part["type"], short_opencode_id(part["id"]), snippet.to_s.squish.truncate(50)].compact.reject(&:blank?).join(" · ")
    else
      ""
    end
  end

  def footer
    content_tag :footer, nil, class: "footer" do
      left_part = content_tag :div, nil do
        concat link_to "CoreUI", "https://coreui.io"
        concat " "
        concat link_to "Rails Starter Template", "https://git.thape.com.cn/Eric-Guo/coreui-pro-rails-starter"
        concat "  © 2023 Eric-Guo."
      end
      right_part = content_tag :div, nil, class: "ms-auto" do
        concat "Powered by "
        concat link_to "CoreUI PRO UI Components", "https://coreui-doc.redwoodjs.cn/"
      end
      left_part.concat(right_part)
    end
  end
end
