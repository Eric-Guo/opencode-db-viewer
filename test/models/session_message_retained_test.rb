require "test_helper"

class SessionMessageRetainedTest < ActiveSupport::TestCase
  test "maps retained V2 history to the current session" do
    message = session_message_retaineds(:session_message_retained_v2_user)

    assert_equal "session_message_retained", SessionMessageRetained.table_name
    assert_equal sessions(:session_v2_fixture), message.session
    assert_equal [message], message.session.retained_session_messages.to_a
    assert_equal "user", message.message_type
    assert_equal "Retained V2 prompt", message.parsed_data["text"]
    assert_equal Time.zone.at(1_700_000_005), message.time_created_at
  end
end
