class AccountState < ApplicationRecord
  self.table_name = "account_state"

  belongs_to :active_account,
    class_name: "Account",
    foreign_key: :active_account_id,
    inverse_of: :account_states,
    optional: true
end
