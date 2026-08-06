class Message < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "message"

  belongs_to :session, class_name: "LegacySession", foreign_key: :session_id, inverse_of: :messages
  has_many :parts, class_name: "Part", foreign_key: :message_id, inverse_of: :message, dependent: :destroy

  def parsed_data
    @parsed_data ||= parsed_json(data)
  end

  def role
    parsed_data["role"]
  end

  def user?
    role == "user"
  end

  def assistant?
    role == "assistant"
  end

  def parent_id_ref
    parsed_data["parentID"]
  end

  def model_id
    parsed_data["modelID"] || model_data["modelID"]
  end

  def provider_id
    parsed_data["providerID"] || model_data["providerID"]
  end

  def agent
    parsed_data["agent"]
  end

  def mode
    parsed_data["mode"]
  end

  def cost
    parsed_data["cost"]
  end

  def tokens
    parsed_data["tokens"]
  end

  def finish_reason
    parsed_data["finish"]
  end

  def time_created_at
    epoch_time(time_data["created"] || time_created)
  end

  def time_completed_at
    epoch_time(time_data["completed"])
  end

  def summary_title
    summary_data["title"]
  end

  private

  def model_data
    value = parsed_data["model"]
    value.is_a?(Hash) ? value : {}
  end

  def summary_data
    value = parsed_data["summary"]
    value.is_a?(Hash) ? value : {}
  end

  def time_data
    value = parsed_data["time"]
    value.is_a?(Hash) ? value : {}
  end
end
