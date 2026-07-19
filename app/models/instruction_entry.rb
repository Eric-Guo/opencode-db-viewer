class InstructionEntry < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "instruction_entry"
  self.primary_key = %i[session_id key]

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :instruction_entries

  def value_data
    @value_data ||= parsed_json(value, fallback: nil)
  end

  def removed?
    self[:removed].to_i == 1
  end
end
