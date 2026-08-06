require "test_helper"

class SessionMessageTest < ActiveSupport::TestCase
  test "type column is treated as message data rather than STI" do
    message = session_messages(:session_message_v2_assistant)

    assert_instance_of SessionMessage, message
    assert_equal sessions(:session_v2_fixture), message.session
    assert_equal "assistant", message.message_type
    assert message.assistant?
  end

  test "decodes current assistant payload" do
    message = session_messages(:session_message_v2_assistant)

    assert_equal "test-model", message.model_id
    assert_equal "test-provider", message.provider_id
    assert_equal "Current schema assistant response", message.content.second["text"]
    assert_equal "Raw result fixture", message.content.third.dig("state", "result", "items", 0, "name")
    assert_equal 500, message.tokens.dig("cache", "read")
    assert_equal Time.zone.at(1_700_000_010.2), message.time_created_at
  end
end
