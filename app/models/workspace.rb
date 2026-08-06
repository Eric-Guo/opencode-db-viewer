class Workspace < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "workspace"
  self.inheritance_column = nil

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :workspaces
  has_many :sessions, class_name: "Session", foreign_key: :workspace_id, inverse_of: :workspace
  has_many :legacy_sessions, class_name: "LegacySession", foreign_key: :workspace_id, inverse_of: :workspace

  def workspace_type
    self[:type]
  end

  def extra_data
    @extra_data ||= parsed_json(extra)
  end

  def time_used_at
    epoch_time(time_used)
  end
end
