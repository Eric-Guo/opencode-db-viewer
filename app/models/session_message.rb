class SessionMessage < ApplicationRecord
  include OpenCodeRecord
  include SessionMessageData

  self.table_name = "session_message"
  self.inheritance_column = nil

  has_many :session_parts, -> { order(:ordinal) }, foreign_key: :message_id, dependent: :delete_all

  def content
    return super unless assistant?

    session_parts.map(&:parsed_data) + super
  end

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :session_messages
end
