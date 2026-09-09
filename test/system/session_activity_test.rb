require "application_system_test_case"

class SessionActivityTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    users(:user_fangzixue).update!(preferred_language: "en")
    login_as users(:user_fangzixue), scope: :user
  end

  teardown do
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
    Warden.test_reset!
  end

  test "browse browser calls, search activity, and navigate subagents at wide and narrow sizes" do
    visit project_session_path("project-session-v2", "session-v2-fixture")
    assert_selector "button[data-category='conversation'][aria-pressed='true']"
    assert_no_selector "[data-categories='events']"
    click_button "Browser", exact: true
    assert_selector ".oc-nested-call", count: 3
    assert_no_selector ".oc-tool--subagents"
    find(".oc-nested-call", text: "browser.tabs.open").find("summary").click
    assert_selector "pre", text: '"url": "https://example.com"'
    find("input[data-timeline-target='search']").fill_in with: "missing-browser-operation"
    assert_selector "[data-timeline-target='empty']", text: "No activity matches this filter."
    find("input[data-timeline-target='search']").fill_in with: ""
    assert_selector ".oc-nested-call", count: 3

    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 1, mobile: true)
    assert_selector ".wrapper", style: {"padding-left" => "0px"}
    assert_selector "button[data-category='browser'][aria-pressed='true']"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth"), "Page should fit narrow screens"
    find(".oc-timeline").scroll_to(:top)
    click_button "Subagents", exact: true
    within ".oc-tool--subagents" do
      click_link "Review browser integration"
    end
    assert_selector ".oc-overview", text: "Review browser integration"
    assert_link "session-v2-fixture"
  end

  test "project filters navigate to child sessions" do
    page.driver.browser.manage.window.resize_to(1400, 1000)
    visit project_path("project-session-v2")
    select "Subagent sessions", from: "Session kind"
    fill_in "Search sessions by title, agent, or ID", with: "explore"
    click_button "Filter", exact: true
    assert_selector "table.table-striped tbody tr", count: 1
    assert_selector "table.table-striped", text: "Review browser integration"
  end
end
