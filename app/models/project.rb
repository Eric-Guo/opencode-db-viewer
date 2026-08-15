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
  has_many :worktrees,
    class_name: "Worktree",
    foreign_key: :project_id,
    inverse_of: :project,
    dependent: :destroy
  has_many :workspaces, -> { distinct }, through: :sessions

  # opencode can create multiple project rows for the same worktree (for
  # example when a different app version derives the project id differently).
  # Sessions may be attached to any of those rows, so group them by worktree.
  def worktree_project_ids
    @worktree_project_ids ||=
      worktree.present? ? Project.where(worktree: worktree).pluck(:id) : [id]
  end

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
