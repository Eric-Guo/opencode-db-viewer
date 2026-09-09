# Presentation boundary for tool payloads retained across OpenCode versions.
class SessionTool
  attr_reader :data, :state, :input, :metadata, :name, :status

  def initialize(data)
    @data = data
    @state = data["state"].is_a?(Hash) ? data["state"] : {}
    @input = state["input"].is_a?(Hash) ? state["input"] : {}
    @metadata = state["metadata"].is_a?(Hash) ? state["metadata"] : {}
    @name = data["name"].to_s
    @status = (metadata["error"] == true) ? "error" : state["status"].to_s
  end

  def subagent?
    name == "subagent"
  end

  def browser?
    name.start_with?("browser.", "browser_")
  end

  def category
    return "subagents" if subagent?
    return "browser" if browser?

    "tools"
  end

  def calls
    @calls ||= Array.wrap(metadata["toolCalls"]).filter_map do |call|
      next unless call.is_a?(Hash) && call["tool"].is_a?(String)

      SessionTool.new("name" => call["tool"], "state" => call)
    end
  end

  def session_id
    return unless subagent?

    metadata["sessionID"].presence || input["sessionID"].presence
  end

  def summary
    return input["description"].to_s if subagent?
    return [input["url"], input["tabID"], input["ref"]].compact.join(" · ") if browser?

    (input["description"].presence || input["command"].presence || input["filePath"].presence || input["path"]).to_s
  end

  def duration_ms
    time = data["time"].is_a?(Hash) ? data["time"] : {}
    return unless time["completed"].is_a?(Numeric) && time["created"].is_a?(Numeric)

    [time["completed"] - time["created"], 0].max
  end
end
