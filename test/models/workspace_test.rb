require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  test "decodes provider binding and timestamps" do
    workspace = workspaces(:workspace_show_new)

    assert_equal "sandbox-new", workspace.binding_data["sandboxId"]
    assert_equal Time.zone.at(1_700_000_020), workspace.created_time
    assert_equal Time.zone.at(1_700_000_030), workspace.last_used_time
  end
end
