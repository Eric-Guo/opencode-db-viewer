require "application_system_test_case"

class CoreuiProTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    users(:user_fangzixue).update!(preferred_language: "en", sidebar_narrow: false)
    login_as users(:user_fangzixue), scope: :user
  end

  teardown do
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
    Warden.test_reset!
  end

  test "project search supports shortcut, dismissal, suggestions, and free text" do
    visit projects_path
    assert_selector ".search-button-key", count: 2
    find("body").send_keys([:control, "/"])
    assert_selector "#project-search-modal.show"
    assert_selector "#project-search-input:focus"
    assert_selector ".autocomplete-option", count: 8
    assert_suggestions_above_actions
    find("#project-search-input").send_keys(:escape)
    assert_no_selector "#project-search-modal.show"
    assert_selector "[data-coreui-search-button]:focus"

    click_button "Find a project"
    assert_selector "#project-search-input:focus"
    fill_in "project-search-input", with: "/tmp/session-v2-project"
    assert_selector ".autocomplete-option", count: 1
    assert_selector ".autocomplete-option", text: "session-v2-project"
    find("#project-search-input").send_keys(:down)
    find(".autocomplete-option:focus").send_keys(:enter)
    assert_field "project-search-input", with: "session-v2-project"
    within "#project-search-modal" do
      click_button "Search", exact: true
    end
    assert_current_path project_path("project-session-v2")

    click_button "Find a project"
    assert_selector "#project-search-input:focus"
    fill_in "project-search-input", with: "no-such-project"
    assert_selector "#project-search-hint", text: "No projects match your search."
    find("#project-search-input").send_keys(:enter)
    assert_current_path projects_path(q: "no-such-project")
    assert_selector "table", text: "No projects match your search."
    assert_no_selector "#project-search-modal.show"
  end

  test "filter chips remove individual conditions and clear the full filter" do
    visit project_path("project-session-v2", kind: "subagents", state: "unarchived", q: "explore")
    assert_selector ".oc-active-filters .chip", count: 3
    find("button[aria-label='Remove filter: Subagent sessions']").click
    assert_current_path project_path("project-session-v2", q: "explore", state: "unarchived")
    assert_selector ".oc-active-filters .chip", count: 2
    find(".oc-active-filters .chip", text: "explore").send_keys(:delete)
    assert_current_path project_path("project-session-v2", state: "unarchived")
    assert_selector ".oc-active-filters .chip", count: 1
    click_link "Clear all"
    assert_current_path project_path("project-session-v2")
    assert_no_selector ".oc-active-filters"
    assert_selector "table.table-striped tbody tr", count: 2
  end

  test "timeline chip set supports keyboard selection and reset without deselecting the active category" do
    visit project_session_path("project-session-v2", "session-v2-fixture")
    conversation = find(".chip[data-category='conversation']")
    conversation.click
    assert_selector ".chip[data-category='conversation'][aria-pressed='true']"
    conversation.send_keys(:end)
    assert_selector ".chip[data-category='all']:focus"
    find(".chip:focus").send_keys(:left)
    assert_selector ".chip[data-category='events']:focus"
    find(".chip:focus").send_keys(:space)
    assert_selector ".chip[data-category='events'][aria-pressed='true']"
    assert_selector "[data-categories='events']"
    find(".chip:focus").send_keys(:left)
    find(".chip:focus").send_keys(:enter)
    assert_selector ".chip[data-category='browser'][aria-pressed='true']"
    assert_selector ".oc-nested-call", count: 3
    fill_in "Search activity on this page", with: "missing"
    assert_selector "[data-timeline-target='empty']"
    click_button "Reset", exact: true
    assert_field "Search activity on this page", with: ""
    assert_selector ".chip[data-category='conversation'][aria-pressed='true']"
    assert_no_selector "[data-categories='events']"
    assert_no_selector "[data-timeline-target='empty']"
  end

  test "viewer components fit desktop and phone layouts in light and dark themes" do
    [1440, 390].each do |width|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: 1000, deviceScaleFactor: 1, mobile: width < 600)
      %w[light dark].each do |theme|
        visit project_path("project-session-v2", kind: "subagents", q: "explore")
        find("button[aria-label='Select color theme']").click
        find("button[data-coreui-theme-value='#{theme}']").click
        assert_selector "html[data-coreui-theme='#{theme}']", visible: :all
        assert_selector ".oc-active-filters .chip", count: 2
        page.execute_script("arguments[0].scrollIntoView({block: 'center', behavior: 'instant'})", find(".oc-session-filters"))
        assert_fits "project-#{width}-#{theme}"

        visit project_session_path("project-session-v2", "session-v2-fixture")
        assert_selector ".sidebar-nav-tree", visible: :all
        assert_selector "#sidebar .nav-group.show a.active", text: "session-v2-fixture", visible: :all
        page.execute_script("arguments[0].scrollIntoView({block: 'center', behavior: 'instant'})", find(".oc-timeline-toolbar"))
        assert_fits "session-#{width}-#{theme}"

        click_button "Find a project"
        assert_selector "#project-search-input:focus"
        assert_selector ".autocomplete-option", count: 8
        assert_suggestions_above_actions
        assert_fits "search-recent-#{width}-#{theme}"
        fill_in "project-search-input", with: "session-v2"
        assert_selector ".autocomplete-option", count: 1
        assert_selector ".autocomplete-option", text: "session-v2-project"
        assert_fits "search-#{width}-#{theme}"
        find("button[aria-label='Close search']").click
      end
    end
  end

  private

  def assert_suggestions_above_actions
    assert page.evaluate_script(<<~JS), "Project suggestions should not cover the search actions"
      document.querySelector('#project-search-modal .autocomplete-dropdown').getBoundingClientRect().bottom <=
        document.querySelector('#project-search-modal .modal-footer').getBoundingClientRect().top
    JS
  end

  def assert_fits(name)
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth"), name
    return unless ENV["COREUI_SCREENSHOTS"]

    page.save_screenshot(Rails.root.join("tmp/screenshots/coreui-pro", "#{name}.png")) # standard:disable Lint/Debugger
  end
end
