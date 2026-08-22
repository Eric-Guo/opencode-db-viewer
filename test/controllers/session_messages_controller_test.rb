require "test_helper"

class SessionMessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect download to login when not signed in" do
    get project_session_message_url(projects(:project_session_v2), "session-v2-fixture", "msg-v2-assistant-fixture", content: 2, item: 3)
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should download a tool content file item stored as a data URL" do
    sign_in users(:user_fangzixue)
    get project_session_message_url(projects(:project_session_v2), "session-v2-fixture", "msg-v2-assistant-fixture", content: 2, item: 3)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_equal "%PDF-1.4 fixture\n", response.body
    assert_includes response.headers["Content-Disposition"], "attachment"
    assert_includes response.headers["Content-Disposition"], "inline.pdf"
  end

  test "should return not found for a file item without a data URL" do
    sign_in users(:user_fangzixue)
    get project_session_message_url(projects(:project_session_v2), "session-v2-fixture", "msg-v2-assistant-fixture", content: 2, item: 2)

    assert_response :not_found
  end

  test "should return not found for a non-file content item" do
    sign_in users(:user_fangzixue)
    get project_session_message_url(projects(:project_session_v2), "session-v2-fixture", "msg-v2-assistant-fixture", content: 0)

    assert_response :not_found
  end
end
