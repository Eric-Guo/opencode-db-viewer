require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "time_created_at converts unix seconds" do
    project = Project.new(time_created: 1_700_000_000)

    assert_equal Time.zone.at(1_700_000_000), project.time_created_at
  end

  test "time_updated_at converts unix milliseconds" do
    project = Project.new(time_updated: 1_700_000_000_123)

    assert_in_delta Time.zone.at(1_700_000_000.123).to_f, project.time_updated_at.to_f, 0.0001
  end
end
