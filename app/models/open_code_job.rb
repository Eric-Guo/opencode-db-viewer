class OpenCodeJob < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "job"
  self.primary_key = "notification_id"

  def job_id
    self[:id]
  end

  def recovery_data
    @recovery_data ||= parsed_json(recovery)
  end

  def description
    title.presence || recovery_data["command"] || recovery_data["description"] || recovery_data["path"] || job_id
  end

  def time_created_at
    epoch_time(time_created)
  end

  def time_updated_at
    epoch_time(time_updated)
  end
end
