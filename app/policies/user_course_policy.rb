class UserCoursePolicy < ApplicationPolicy
  def deliver?
    update?
  end
end
