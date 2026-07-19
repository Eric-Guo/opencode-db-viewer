class Permission < ApplicationRecord
  self.table_name = "permission"

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :permissions
end
