class SessionPart < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session_part"
  self.primary_key = [:message_id, :ordinal]
  self.inheritance_column = nil

  belongs_to :session_message, foreign_key: :message_id

  def parsed_data
    @parsed_data ||= parsed_json(data)
  end
end
