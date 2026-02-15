class ControlAccount < ApplicationRecord
  self.table_name = "control_account"
  self.primary_key = %i[email url]
end
