require "test_helper"

class SessionInboxTest < ActiveSupport::TestCase
  test "decodes the current inbox payload" do
    item = session_inboxes(:session_inbox_v2_user)

    assert_equal sessions(:session_v2_fixture), item.session
    assert_equal "user", item.inbox_type
    assert_equal "Queued current schema prompt", item.parsed_payload["text"]
    assert_equal Time.zone.at(1_700_000_040), item.time_created_at
  end
end
