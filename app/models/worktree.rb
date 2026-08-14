class Worktree < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "worktree"
  self.primary_key = %i[project_id directory]

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :worktrees

  def time_created_at
    epoch_time(time_created)
  end
end
