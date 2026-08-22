require "test_helper"

class PartsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect download to login when not signed in" do
    get project_session_part_url(projects(:project_session_file), "session-file-parts-fixture", parts(:part_msg_user_file_tool_pdf_fixture))
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should download a tool attachment stored as a data URL" do
    part = parts(:part_msg_user_file_tool_pdf_fixture)

    sign_in users(:user_fangzixue)
    get project_session_part_url(projects(:project_session_file), "session-file-parts-fixture", part, attachment: 0)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_equal "%PDF-1.4 fixture\n", response.body
    assert_includes response.headers["Content-Disposition"], "attachment"
    assert_includes response.headers["Content-Disposition"], "demo.pdf"
  end

  test "should return not found for an attachment without a data URL" do
    sign_in users(:user_fangzixue)
    get project_session_part_url(projects(:project_session_file), "session-file-parts-fixture", parts(:part_msg_user_file_attachment_fixture))

    assert_response :not_found
  end
end
