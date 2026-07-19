class Credential < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "credential"

  def active?
    self[:active].to_i == 1
  end

  def value_data
    @value_data ||= parsed_json(value, fallback: nil)
  end

  def time_created_at
    epoch_time(time_created)
  end

  def time_updated_at
    epoch_time(time_updated)
  end
end
