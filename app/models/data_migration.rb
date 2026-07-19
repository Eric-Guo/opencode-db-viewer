class DataMigration < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "data_migration"
  self.primary_key = "name"

  def time_completed_at
    epoch_time(time_completed)
  end
end
