class SessionMessageRetained < ApplicationRecord
  include OpenCodeRecord
  include SessionMessageData

  self.table_name = "session_message_retained"
  self.inheritance_column = nil

  belongs_to :session,
    class_name: "Session",
    foreign_key: :session_id,
    inverse_of: :retained_session_messages
end
