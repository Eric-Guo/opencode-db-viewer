require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect to login when not signed in" do
    get projects_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should get index when signed in" do
    sign_in users(:user_fangzixue)
    get projects_url
    assert_response :success
    assert_select "th", text: I18n.t("projects.index.time_created")
    assert_select "th", text: I18n.t("projects.index.time_updated")
  end

  test "should link project name to show page in index" do
    project = projects(:project_order_old)

    sign_in users(:user_fangzixue)
    get projects_url

    assert_response :success
    assert_select "a[href=?]", project_path(project), text: project.name
  end

  test "should redirect show to login when not signed in" do
    get project_url(projects(:project_show_auth))
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should raise not found when signed in and project does not exist" do
    sign_in users(:user_fangzixue)
    get project_url("project-does-not-exist")
    assert_response :not_found
  end

  test "should get show when signed in and order sessions by time_updated desc" do
    project = projects(:project_show_with_sessions)
    old_title = sessions(:session_show_old).title
    new_title = sessions(:session_show_new).title

    sign_in users(:user_fangzixue)
    get project_url(project)

    assert_response :success
    assert_select "th", text: I18n.t("projects.show.session_title")
    assert_select "div", text: I18n.t("projects.show.total_sessions")
    assert_select "div", text: I18n.t("projects.show.total_additions")
    assert_select "div", text: I18n.t("projects.show.total_deletions")
    assert_select "tbody tr", count: 2
    assert_includes response.body, old_title
    assert_includes response.body, new_title
    assert_operator response.body.index(new_title), :<, response.body.index(old_title)
  end

  test "should render empty sessions state" do
    sign_in users(:user_fangzixue)
    get project_url(projects(:project_show_empty))

    assert_response :success
    assert_includes response.body, I18n.t("projects.show.no_sessions")
  end

  test "should order projects by time_updated desc" do
    old_name = projects(:project_order_old).name
    new_name = projects(:project_order_new).name

    sign_in users(:user_fangzixue)
    get projects_url

    assert_response :success
    assert_includes response.body, old_name
    assert_includes response.body, new_name
    assert_operator response.body.index(new_name), :<, response.body.index(old_name)
  end
end
