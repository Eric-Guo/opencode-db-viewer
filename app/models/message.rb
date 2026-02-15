class Message < ApplicationRecord
  self.table_name = "message"

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :messages
  has_many :parts, class_name: "Part", foreign_key: :message_id, inverse_of: :message, dependent: :destroy
end
