class SessionShare < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session_share"
  self.primary_key = "session_id"

  belongs_to :session, class_name: "LegacySession", foreign_key: :session_id, inverse_of: :session_share

  def time_created_at
    epoch_time(time_created)
  end

  def time_updated_at
    epoch_time(time_updated)
  end
end
