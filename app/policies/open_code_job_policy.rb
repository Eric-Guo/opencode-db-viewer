class OpenCodeJobPolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
