class SessionInbox < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session_inbox"
  self.inheritance_column = nil

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :session_inboxes

  def parsed_payload
    @parsed_payload ||= parsed_json(payload)
  end

  def inbox_type
    self[:type]
  end

  def time_created_at
    epoch_time(time_created)
  end
end
