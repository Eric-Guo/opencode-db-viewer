class InstructionBlob < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "instruction_blob"
  self.primary_key = "hash"

  def value_data
    @value_data ||= parsed_json(value, fallback: nil)
  end
end
