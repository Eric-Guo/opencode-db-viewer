require "application_system_test_case"

class ViewerWorkspaceTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    users(:user_fangzixue).update!(preferred_language: "en")
    login_as users(:user_fangzixue), scope: :user
  end

  teardown do
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
    Warden.test_reset!
  end

  test "split messages render safe markdown and stored attachments" do
    visit project_session_path("project-current-schema", "session-current-schema")
    assert_selector ".oc-markdown h2", text: "Schema supported"
    assert_selector ".oc-markdown strong", text: "new fields"
    assert_selector ".oc-markdown table td", text: "session_part"
    assert_no_selector ".oc-markdown script", visible: :all
    assert_no_selector ".oc-markdown [onerror]", visible: :all
    assert_nil page.evaluate_script("window.markdownInjected")
    assert_selector ".oc-source", text: "View source"
    assert_selector ".oc-attachment", text: "Media unavailable"
    assert page.evaluate_script("document.querySelector('img[alt=\"schema.png\"]').complete && document.querySelector('img[alt=\"schema.png\"]').naturalWidth === 1")

    click_button "Inspect session", exact: true
    assert_selector "#session-inspector", text: "Last execution started"
    click_button "Background work", exact: true
    assert_selector "#inspector-jobs .oc-work-item", count: 4
    click_button "Schedules", exact: true
    assert_selector "#inspector-schedules .oc-work-item", count: 2
    find("#session-inspector button[aria-label='Close inspector']").click
    assert_selector "[data-inspector-target='toggle']:focus"

    visit schedules_path(status: "done")
    assert_selector ".oc-work-item", text: "No session"
    visit background_jobs_path(kind: "image")
    assert_selector ".oc-work-item", text: "Image background work"
  end

  test "viewer drawer layouts fit each theme and provide representative screenshots" do
    [1440, 820, 390].each do |width|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: 1000, deviceScaleFactor: 1, mobile: width < 600)
      %w[light dark].each do |theme|
        visit project_session_path("project-current-schema", "session-current-schema")
        find("button[aria-label='Select color theme']").click
        find("button[data-coreui-theme-value='#{theme}']").click
        assert_selector ".oc-markdown h2", text: "Schema supported"
        assert_fits
        click_button "Inspect session", exact: true
        assert_selector "#session-inspector"
        click_button "Background work", exact: true
        assert_selector "#inspector-jobs .oc-work-item", count: 4
        assert_fits
        if width == 1440 && ENV["VIEWER_SCREENSHOTS"]
          page.save_screenshot(Rails.root.join("tmp/screenshots/viewer-#{theme}.png")) # standard:disable Lint/Debugger
        end
        find("#session-inspector").send_keys(:escape)
        assert_no_selector "#session-inspector"
        assert_selector "[data-inspector-target='toggle']:focus"
        visit project_path("project-current-schema")
        assert_fits
        visit schedules_path
        assert_fits
      end
    end
  end

  private

  def assert_fits
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth"), "Viewer must fit the viewport"
  end
end
