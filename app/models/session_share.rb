class SessionShare < ApplicationRecord
  self.table_name = "session_share"
  self.primary_key = "session_id"

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :session_share
end
