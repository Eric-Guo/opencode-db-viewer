require "application_system_test_case"

class CoreuiV5Test < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    users(:user_fangzixue).update!(preferred_language: "en", sidebar_narrow: false)
    login_as users(:user_fangzixue), scope: :user
  end

  teardown do
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [])
    Warden.test_reset!
  end

  test "color modes persist and auto follows the system on session pages" do
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [{name: "prefers-color-scheme", value: "light"}])
    visit project_session_path("project-session-v2", "session-v2-fixture")

    select_theme "light"
    assert_selector ".wrapper", style: {"background-color" => "rgba(243, 244, 247, 1)"}

    select_theme "dark"
    assert_selector ".wrapper", style: {"background-color" => "rgba(42, 48, 61, 1)"}
    click_button "Browser", exact: true
    find(".oc-nested-call", text: "browser.tabs.open").find("summary").click
    assert_equal "rgba(42, 48, 61, 1)", find(".oc-pre", text: "https://example.com").style("background-color").fetch("background-color")
    refresh
    assert_selector "html[data-coreui-theme='dark']", visible: :all

    select_theme "auto"
    assert_selector "html[data-coreui-theme='light']", visible: :all
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [{name: "prefers-color-scheme", value: "dark"}])
    assert_selector "html[data-coreui-theme='dark']", visible: :all

    logout(:user)
    visit new_user_session_path
    assert_selector "html[data-coreui-theme='dark']", visible: :all
  end

  test "sidebar preference persists and navigation works on tablet and phone widths" do
    visit projects_path
    find("button[aria-label='Toggle narrow sidebar']").click
    assert_selector "#sidebar.sidebar-narrow-unfoldable"
    assert_selector ".wrapper", style: {"padding-left" => "64px"}
    refresh
    assert_selector "#sidebar.sidebar-narrow-unfoldable"
    find("#sidebar").hover
    find("button[aria-label='Toggle narrow sidebar']").click
    assert_no_selector "#sidebar.sidebar-narrow-unfoldable"
    refresh
    assert_no_selector "#sidebar.sidebar-narrow-unfoldable"

    [820, 390].each do |width|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: 844, deviceScaleFactor: 1, mobile: true)
      assert_selector ".wrapper", style: {"padding-left" => "0px"}
      find("button[aria-label='Toggle navigation']").click
      assert_selector "#sidebar.show"
      find("button[aria-label='Close navigation']").click
      assert_no_selector "#sidebar.show"
      assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    end
  end

  test "navigation groups and account dropdown initialize on the application page" do
    visit root_path
    find("#sidebar .nav-group-toggle").click
    assert_selector "#sidebar .nav-group.show .nav-group-items a", minimum: 1
    find(".header [data-coreui-toggle='dropdown'][data-action='expender#click']").click
    assert_selector ".header .dropdown-menu.show", text: users(:user_fangzixue).email
  end

  test "admin charts, tables, and modal selects initialize from the application bundle" do
    users(:user_guochunzhong).update!(preferred_language: "en")
    login_as users(:user_guochunzhong), scope: :user
    visit admin_root_path
    assert_selector "[data-controller='dashboard'][data-chart-initialized='true'] canvas"

    visit admin_users_path
    select_theme "dark"
    assert_selector "[data-controller='datatables'] tbody tr", minimum: 2
    2.times do
      find("a[data-controller='modal'][href$='/edit']", match: :first).click
      assert_selector "#coreuiModal.show .selectize-input", style: {"background-color" => "rgba(33, 38, 49, 1)"}
      assert_selector "#coreuiModal .modal-dialog", style: {"transform" => "none"}
      find("#coreuiModal .btn-close").click
      assert_no_selector "#coreuiModal.show"
      assert_no_selector ".modal-backdrop"
      assert_selector "[data-controller='datatables'] tbody tr", minimum: 2
    end

    visit admin_roles_path
    find("a[data-controller='modal'][href$='/edit']", match: :first).click
    assert_selector "#coreuiModal.show [data-controller='selectize-user-ids'] .selectize-control"
  end

  private

  def select_theme(theme)
    find("button[aria-label='Select color theme']").click
    find("button[data-coreui-theme-value='#{theme}']").click
    assert_selector "button[data-coreui-theme-value='#{theme}'][aria-pressed='true']", visible: :all
  end
end
