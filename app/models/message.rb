class Message < ApplicationRecord
  self.table_name = "message"

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :messages
  has_many :parts, class_name: "Part", foreign_key: :message_id, inverse_of: :message, dependent: :destroy

  def parsed_data
    @parsed_data ||= begin
      parsed = JSON.parse(data)
      parsed.is_a?(Hash) ? parsed : {}
    end
  rescue JSON::ParserError, TypeError
    {}
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
    ts = time_data["created"]
    return if ts.blank?
    ts = ts.to_i
    ts /= 1000.0 if ts > 99_999_999_999
    Time.zone.at(ts)
  end

  def time_completed_at
    ts = time_data["completed"]
    return if ts.blank?
    ts = ts.to_i
    ts /= 1000.0 if ts > 99_999_999_999
    Time.zone.at(ts)
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
