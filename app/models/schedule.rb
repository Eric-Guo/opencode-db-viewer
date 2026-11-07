class Schedule < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "schedule"

  %w[action when check state].each do |field|
    define_method("#{field}_data") { parsed_json(self[field], fallback: nil) }
  end

  %w[next_due_at ends_at last_fired_at retry_at time_created time_updated].each do |field|
    define_method("#{field}_time") { epoch_time(self[field]) }
  end

  def recurrence
    value = when_data
    return self[:when] unless value.is_a?(Hash)

    [value["type"], value[value["type"]]].compact.join(" ")
  end
end
