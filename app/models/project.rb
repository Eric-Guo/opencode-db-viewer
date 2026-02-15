class Project < ApplicationRecord
  self.table_name = "project"

  has_many :sessions, class_name: "Session", foreign_key: :project_id, inverse_of: :project, dependent: :destroy
  has_one :permission, class_name: "Permission", foreign_key: :project_id, inverse_of: :project, dependent: :destroy

  def time_created_at
    convert_unix_timestamp(time_created)
  end

  def time_updated_at
    convert_unix_timestamp(time_updated)
  end

  private

  def convert_unix_timestamp(value)
    return if value.blank?

    timestamp = value.to_i
    # Drizzle-backed integer timestamps may be stored in milliseconds.
    timestamp /= 1000.0 if timestamp > 99_999_999_999
    Time.zone.at(timestamp)
  end
end
