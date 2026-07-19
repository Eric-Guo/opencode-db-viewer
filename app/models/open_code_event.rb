class OpenCodeEvent < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "event"
  self.inheritance_column = nil

  belongs_to :event_sequence,
    class_name: "EventSequence",
    foreign_key: :aggregate_id,
    primary_key: :aggregate_id,
    inverse_of: :events

  def event_type
    self[:type]
  end

  def parsed_data
    @parsed_data ||= parsed_json(data)
  end

  def created_at_time
    epoch_time(created)
  end
end
