class EventSequence < ApplicationRecord
  self.table_name = "event_sequence"
  self.primary_key = "aggregate_id"

  has_many :events,
    class_name: "OpenCodeEvent",
    foreign_key: :aggregate_id,
    primary_key: :aggregate_id,
    inverse_of: :event_sequence,
    dependent: :destroy
end
