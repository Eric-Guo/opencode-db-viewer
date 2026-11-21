class Automation < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "automation"

  %w[action trigger state event_position].each do |field|
    define_method("#{field}_data") { parsed_json(self[field], fallback: nil) }
  end

  %w[next_due_at expires_at last_run_at retry_at time_created time_updated].each do |field|
    define_method("#{field}_time") { epoch_time(self[field]) }
  end

  def trigger_summary
    value = trigger_data
    return trigger unless value.is_a?(Hash)

    kind = value["type"]
    detail = if kind == "event"
      [value["server"], value["event"]].compact.join(": ")
    else
      value[kind]
    end
    [kind, detail].compact_blank.join(" ").presence || trigger
  end
end
