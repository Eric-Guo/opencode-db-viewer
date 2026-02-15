class Project < ApplicationRecord
  self.table_name = "project"

  has_many :sessions, class_name: "Session", foreign_key: :project_id, inverse_of: :project, dependent: :destroy
  has_one :permission, class_name: "Permission", foreign_key: :project_id, inverse_of: :project, dependent: :destroy
end
