require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "uses the current session table" do
    assert_equal "session_v2", Session.table_name
  end

  test "parses the fork boundary" do
    session = sessions(:session_show_new)

    assert_equal "before", session.fork_boundary_type
    assert_equal "msg-boundary-fixture", session.fork_boundary_message_id
  end

  test "converts idle and viewed epoch timestamps" do
    session = sessions(:session_show_new)

    assert_equal Time.zone.at(1_700_000_040), session.time_idle_at
    assert_equal Time.zone.at(1_700_000_050), session.time_viewed_at
  end
end
