class SessionMessageRetained < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session_message_retained"
  self.inheritance_column = nil

  belongs_to :session,
    class_name: "Session",
    foreign_key: :session_id,
    inverse_of: :retained_session_messages

  def parsed_data
    @parsed_data ||= parsed_json(data)
  end

  def message_type
    self[:type]
  end

  def time_created_at
    epoch_time(time_created)
  end
end
