class Project < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "project"

  has_many :sessions, class_name: "Session", foreign_key: :project_id, inverse_of: :project, dependent: :destroy
  has_many :legacy_sessions,
    class_name: "LegacySession",
    foreign_key: :project_id,
    inverse_of: :project,
    dependent: :destroy
  has_many :permissions, class_name: "Permission", foreign_key: :project_id, inverse_of: :project, dependent: :destroy
  has_many :project_directories,
    class_name: "ProjectDirectory",
    foreign_key: :project_id,
    inverse_of: :project,
    dependent: :destroy
  has_many :workspaces, class_name: "Workspace", foreign_key: :project_id, inverse_of: :project, dependent: :destroy

  def sandboxes_data
    @sandboxes_data ||= parsed_json(sandboxes, fallback: [])
  end

  def commands_data
    @commands_data ||= parsed_json(commands)
  end

  def time_created_at
    epoch_time(time_created)
  end

  def time_updated_at
    epoch_time(time_updated)
  end

  def time_initialized_at
    epoch_time(time_initialized)
  end
end
