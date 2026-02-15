class ProjectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user

      scope.all
    end
  end

  def index?
    user.present?
  end
end
