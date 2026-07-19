class SessionMessage < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session_message"
  self.inheritance_column = nil

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :session_messages

  def parsed_data
    @parsed_data ||= parsed_json(data)
  end

  def message_type
    self[:type]
  end

  def user?
    message_type == "user"
  end

  def assistant?
    message_type == "assistant"
  end

  def text_content
    parsed_data["text"]
  end

  def content
    value = parsed_data["content"]
    value.is_a?(Array) ? value.select { |item| item.is_a?(Hash) } : []
  end

  def files
    value = parsed_data["files"]
    value.is_a?(Array) ? value.select { |item| item.is_a?(Hash) } : []
  end

  def agent
    parsed_data["agent"]
  end

  def model_data
    value = parsed_data["model"]
    value.is_a?(Hash) ? value : {}
  end

  def model_id
    model_data["id"] || model_data["modelID"]
  end

  def provider_id
    model_data["providerID"]
  end

  def finish_reason
    parsed_data["finish"]
  end

  def cost
    parsed_data["cost"]
  end

  def tokens
    value = parsed_data["tokens"]
    value.is_a?(Hash) ? value : {}
  end

  def time_created_at
    epoch_time(parsed_data.dig("time", "created") || time_created)
  end

  def time_completed_at
    epoch_time(parsed_data.dig("time", "completed"))
  end
end
