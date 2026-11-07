class SchedulePolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
