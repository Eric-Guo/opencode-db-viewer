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

  test "should order projects by time_updated desc" do
    old_name = "old-project-#{SecureRandom.hex(6)}"
    new_name = "new-project-#{SecureRandom.hex(6)}"

    Project.create!(
      id: "project-order-old-#{SecureRandom.hex(6)}",
      name: old_name,
      worktree: "/tmp/#{old_name}",
      sandboxes: "[]",
      time_created: 9_000_000_000_000,
      time_updated: 9_000_000_000_000
    )
    Project.create!(
      id: "project-order-new-#{SecureRandom.hex(6)}",
      name: new_name,
      worktree: "/tmp/#{new_name}",
      sandboxes: "[]",
      time_created: 9_100_000_000_000,
      time_updated: 9_100_000_000_000
    )

    sign_in users(:user_fangzixue)
    get projects_url

    assert_response :success
    assert_includes response.body, old_name
    assert_includes response.body, new_name
    assert_operator response.body.index(new_name), :<, response.body.index(old_name)
  end
end
