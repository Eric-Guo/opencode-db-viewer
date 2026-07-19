class Account < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "account"

  has_many :account_states,
    class_name: "AccountState",
    foreign_key: :active_account_id,
    inverse_of: :active_account,
    dependent: :nullify

  def time_created_at
    epoch_time(time_created)
  end

  def time_updated_at
    epoch_time(time_updated)
  end
end
