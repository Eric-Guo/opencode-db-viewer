class AutomationPolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
