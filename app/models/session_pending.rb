class SessionPending < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session_pending"
  self.inheritance_column = nil

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :session_pendings

  def parsed_data
    @parsed_data ||= parsed_json(data)
  end

  def pending_type
    self[:type]
  end

  def time_created_at
    epoch_time(time_created)
  end
end
