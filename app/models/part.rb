class Part < ApplicationRecord
  self.table_name = "part"

  belongs_to :message, class_name: "Message", foreign_key: :message_id, inverse_of: :parts
  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :parts

  def parsed_data
    @parsed_data ||= begin
      parsed = JSON.parse(data)
      parsed.is_a?(Hash) ? parsed : {}
    end
  rescue JSON::ParserError, TypeError
    {}
  end

  def part_type
    parsed_data["type"]
  end

  def text?
    part_type == "text"
  end

  def reasoning?
    part_type == "reasoning"
  end

  def tool?
    part_type == "tool"
  end

  def step_start?
    part_type == "step-start"
  end

  def step_finish?
    part_type == "step-finish"
  end

  def patch?
    part_type == "patch"
  end

  def file?
    part_type == "file"
  end

  def text_content
    parsed_data["text"]
  end

  def tool_name
    parsed_data["tool"]
  end

  def tool_call_id
    parsed_data["callID"]
  end

  def tool_state
    value = parsed_data["state"]
    value.is_a?(Hash) ? value : {}
  end

  def tool_status
    tool_state["status"]
  end

  def tool_input
    tool_state["input"]
  end

  def tool_output
    tool_state["output"]
  end

  def step_finish_tokens
    value = parsed_data["tokens"]
    value.is_a?(Hash) ? value : {}
  end

  def step_finish_cost
    parsed_data["cost"]
  end

  def patch_files
    value = parsed_data["files"]
    value.is_a?(Array) ? value : []
  end

  def file_name
    parsed_data["filename"].presence || source_data["path"]
  end

  def file_mime
    parsed_data["mime"]
  end

  def file_url
    parsed_data["url"]
  end

  private

  def source_data
    value = parsed_data["source"]
    value.is_a?(Hash) ? value : {}
  end
end
