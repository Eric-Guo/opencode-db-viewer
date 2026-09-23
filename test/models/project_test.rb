require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "time_created_at converts unix seconds" do
    project = Project.new(time_created: 1_700_000_000)

    assert_equal Time.zone.at(1_700_000_000), project.time_created_at
  end

  test "time_updated_at converts unix milliseconds" do
    project = Project.new(time_updated: 1_700_000_000_123)

    assert_in_delta Time.zone.at(1_700_000_000.123).to_f, project.time_updated_at.to_f, 0.0001
    assert_equal "2023-11-14 22:13:20.123", project.time_updated_at.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  test "finds workspaces through current sessions" do
    project = projects(:project_show_with_sessions)

    assert_equal %w[workspace-show-new workspace-show-old], project.workspaces.ids.sort
  end

  test "time_active_at converts activity timestamps independently from metadata updates" do
    project = Project.new(time_active: 1_700_000_000_123, time_updated: 1_600_000_000_000)

    assert_in_delta Time.zone.at(1_700_000_000.123).to_f, project.time_active_at.to_f, 0.0001
    project.time_active = 1_700_000_000
    assert_equal Time.zone.at(1_700_000_000), project.time_active_at
  end

  test "time_active_at leaves unrecorded activity unset" do
    assert_nil Project.new.time_active_at
    assert_nil Project.new(time_active: nil).time_active_at
    assert_nil Project.select(:id).first.time_active_at
  end
end
