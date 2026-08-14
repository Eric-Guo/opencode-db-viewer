require "test_helper"

class WorktreeTest < ActiveSupport::TestCase
  test "uses the current worktree table and composite key" do
    worktree = worktrees(:worktree_session_v2_linked)

    assert_equal "worktree", Worktree.table_name
    assert_equal [worktree.project_id, worktree.directory], worktree.id
    assert_equal projects(:project_session_v2), worktree.project
    assert_equal Time.zone.at(1_700_000_010), worktree.time_created_at
  end
end
