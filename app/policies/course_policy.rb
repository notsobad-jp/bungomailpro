class CoursePolicy < ApplicationPolicy
  def update?
    user && user.id == record.owner_id
  end
end
