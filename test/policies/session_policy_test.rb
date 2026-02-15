require "test_helper"

class SessionPolicyTest < ActiveSupport::TestCase
  def test_show_allows_logged_in_user
    user = users(:user_fangzixue)
    policy = SessionPolicy.new(user, Session)
    assert policy.show?
  end

  def test_show_denies_nil_user
    policy = SessionPolicy.new(nil, Session)
    refute policy.show?
  end

  def test_scope_resolves_all_for_logged_in_user
    user = users(:user_fangzixue)
    scope = SessionPolicy::Scope.new(user, Session)
    assert_equal Session.all, scope.resolve
  end

  def test_scope_returns_none_for_nil_user
    scope = SessionPolicy::Scope.new(nil, Session)
    assert_equal Session.none, scope.resolve
  end
end
