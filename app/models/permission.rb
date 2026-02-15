class Permission < ApplicationRecord
  self.table_name = "permission"
  self.primary_key = "project_id"

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :permission
end
