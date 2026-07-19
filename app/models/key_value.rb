class KeyValue < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "kv"
  self.primary_key = "key"

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
