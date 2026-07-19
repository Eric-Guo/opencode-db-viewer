class InstructionState < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "instruction_state"
  self.primary_key = "session_id"

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :instruction_state

  def initial_values_data
    @initial_values_data ||= parsed_json(initial_values)
  end

  def current_values_data
    @current_values_data ||= parsed_json(current_values)
  end
end
