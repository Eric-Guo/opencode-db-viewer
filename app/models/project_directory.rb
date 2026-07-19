class ProjectDirectory < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "project_directory"
  self.primary_key = %i[project_id directory]
  self.inheritance_column = nil

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :project_directories

  def directory_type
    self[:type]
  end

  def time_created_at
    epoch_time(time_created)
  end
end
