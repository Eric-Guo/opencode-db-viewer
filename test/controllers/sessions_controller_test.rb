require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect show to login when not signed in" do
    get project_session_url(projects(:project_show_with_sessions), sessions(:session_show_old))
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should group assistant messages by parent id when signed in" do
    project = projects(:project_session_parent)
    session = sessions(:session_parent_grouping_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "User one prompt"
    assert_includes response.body, "User two prompt"
    assert_includes response.body, "Assistant for user one"
    assert_operator response.body.index("Assistant for user one"), :<, response.body.index("User two prompt")
  end

  test "should render user file attachments" do
    project = projects(:project_session_file)
    session = sessions(:session_file_parts_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "demo.png"
    assert_select "a[href=?]", "https://example.com/demo.png", text: I18n.t("sessions.show.open")
  end

  test "should group assistant followups by assistant parent id when signed in" do
    project = projects(:project_session_assistant_parent)
    session = sessions(:session_assistant_parent_grouping_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "Assistant first response"
    assert_includes response.body, "Assistant follow-up response"
    assert_operator response.body.index("Assistant follow-up response"), :<, response.body.index("Second user prompt")
  end

  test "should keep orphan assistant chain in chronological order when signed in" do
    project = projects(:project_session_orphan_assistant)
    session = sessions(:session_orphan_assistant_grouping_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "Assistant orphan root response"
    assert_includes response.body, "Assistant orphan child response"
    assert_includes response.body, "Prompt after orphan chain"
    assert_operator response.body.index("Assistant orphan root response"), :<, response.body.index("Prompt after orphan chain")
    assert_operator response.body.index("Assistant orphan child response"), :<, response.body.index("Prompt after orphan chain")
  end
end
