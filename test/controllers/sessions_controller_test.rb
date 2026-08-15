require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect show to login when not signed in" do
    get project_session_url(projects(:project_show_with_sessions), sessions(:session_show_old))
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should redirect destroy to login when not signed in" do
    delete project_session_url(projects(:project_show_with_sessions), sessions(:session_show_old))
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should destroy session and redirect to project page" do
    project = projects(:project_show_with_sessions)
    session = sessions(:session_show_old)

    sign_in users(:user_fangzixue)
    assert_difference -> { Session.count }, -1 do
      delete project_session_url(project, session)
    end
    assert_redirected_to project_path(project)
  end

  test "should destroy legacy session and redirect to project page" do
    project = projects(:project_session_parent)
    session = legacy_sessions(:session_legacy_only_fixture)

    sign_in users(:user_fangzixue)
    assert_difference -> { LegacySession.count }, -1 do
      delete project_session_url(project, session.id)
    end
    assert_redirected_to project_path(project)
  end

  test "should render a nullable title and the current fork boundary" do
    project = projects(:project_show_with_sessions)
    session = sessions(:session_show_new)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_select ".card-header strong", text: session.slug
    assert_includes response.body, "modal-new"
    assert_includes response.body, I18n.t("sessions.show.execution_claimed")
    assert_includes response.body, I18n.t("sessions.show.resume_attempts", count: 2)
    assert_includes response.body, session.fork_session_id
    assert_includes response.body, I18n.t("sessions.show.fork_boundaries.before", message: "msg-boundary-fixture")
  end

  test "should render legacy messages and parts in storage order" do
    project = projects(:project_session_parent)
    session = sessions(:session_parent_grouping_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "message / part"
    assert_includes response.body, "User one prompt"
    assert_includes response.body, "User two prompt"
    assert_includes response.body, "Assistant for user one"
    assert_operator response.body.index("User one prompt"), :<, response.body.index("User two prompt")
    assert_operator response.body.index("User two prompt"), :<, response.body.index("Assistant for user one")
  end

  test "should render legacy file attachments" do
    project = projects(:project_session_file)
    session = sessions(:session_file_parts_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "demo.png"
    assert_select "a[href=?]", "https://example.com/demo.png", text: I18n.t("sessions.show.open")
  end

  test "should render legacy part payloads no longer represented by the current schema" do
    project = projects(:project_session_assistant_parent)
    session = sessions(:session_assistant_parent_grouping_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "step-start"
    assert_includes response.body, "step-finish"
    assert_includes response.body, "tool-calls"
    assert_includes response.body, "1234567890"
    assert_includes response.body, "mcp_debug"
    assert_includes response.body, I18n.t("sessions.show.tool_output")
    assert_includes response.body, "Legacy result fixture"
  end

  test "should prefer and render current sequenced session messages" do
    project = projects(:project_session_v2)
    session = sessions(:session_v2_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "session_message"
    assert_includes response.body, "Current schema user prompt"
    assert_includes response.body, "Current schema reasoning"
    assert_includes response.body, "Current schema assistant response"
    assert_includes response.body, I18n.t("sessions.show.tool_content")
    assert_includes response.body, I18n.t("sessions.show.tool_structured")
    assert_includes response.body, I18n.t("sessions.show.tool_result")
    assert_includes response.body, "Content result fixture"
    assert_includes response.body, "Structured result fixture"
    assert_includes response.body, "Raw result fixture"
    assert_includes response.body, "request-fixture"
    assert_includes response.body, "response-fixture"
    assert_includes response.body, "test-provider/test-model"
    assert_includes response.body, "test-workspace-provider"
    assert_select ".card-header strong", text: I18n.t("sessions.show.session_inbox")
    assert_includes response.body, "inbox-v2-user-fixture"
    assert_includes response.body, "Queued current schema prompt"
    assert_includes response.body, "queue"
    assert_operator response.body.index("Current schema user prompt"), :<, response.body.index("Current schema assistant response")
  end

  test "should show session attached to a duplicate project row with the same worktree" do
    project = projects(:project_show_sibling_main)
    session = sessions(:session_show_sibling_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "sibling-session-title-fixture"
  end

  test "should destroy session attached to a duplicate project row with the same worktree" do
    project = projects(:project_show_sibling_main)
    session = sessions(:session_show_sibling_fixture)

    sign_in users(:user_fangzixue)
    assert_difference -> { Session.count }, -1 do
      delete project_session_url(project, session)
    end
    assert_redirected_to project_path(project)
  end

  test "should collapse consecutive part update events of the same part into one row" do
    project = projects(:project_session_v2)
    session = sessions(:session_v2_fixture)

    sign_in users(:user_fangzixue)
    get project_session_url(project, session)

    assert_response :success
    assert_includes response.body, "×3"
    assert_equal 1, response.body.scan("prt-collapse-aaa-fixture").size
    assert_equal 1, response.body.scan("prt-collapse-bbb-fixture").size
    assert_includes response.body, "Collapse chunk final"
    assert_operator response.body.index("Collapse chunk final"), :<, response.body.index("session.updated")
  end
end
