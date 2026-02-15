require "test_helper"

class ProjectPolicyTest < ActiveSupport::TestCase
  def test_index_allows_logged_in_user
    user = users(:user_fangzixue)
    policy = ProjectPolicy.new(user, Project)
    assert policy.index?
  end

  def test_index_denies_nil_user
    policy = ProjectPolicy.new(nil, Project)
    refute policy.index?
  end

  def test_scope_resolves_all_for_logged_in_user
    user = users(:user_fangzixue)
    scope = ProjectPolicy::Scope.new(user, Project)
    assert_equal Project.all, scope.resolve
  end

  def test_scope_returns_none_for_nil_user
    scope = ProjectPolicy::Scope.new(nil, Project)
    assert_equal Project.none, scope.resolve
  end
end
