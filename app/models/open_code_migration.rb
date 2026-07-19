class OpenCodeMigration < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "migration"

  def time_completed_at
    epoch_time(time_completed)
  end
end
