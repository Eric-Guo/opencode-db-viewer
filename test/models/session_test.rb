require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "parses the fork boundary" do
    session = sessions(:session_show_new)

    assert_equal "before", session.fork_boundary_type
    assert_equal "msg-boundary-fixture", session.fork_boundary_message_id
  end
end
