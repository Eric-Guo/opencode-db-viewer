class SessionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user

      scope.all
    end
  end

  def show?
    user.present?
  end
end
