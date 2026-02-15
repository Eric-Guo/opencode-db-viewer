class Part < ApplicationRecord
  self.table_name = "part"

  belongs_to :message, class_name: "Message", foreign_key: :message_id, inverse_of: :parts
  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :parts
end
