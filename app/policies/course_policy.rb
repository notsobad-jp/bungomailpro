class CoursePolicy < ApplicationPolicy
  def show?
    case record.status
    when 1  # draft
      user.id == record.owner_id
    when 2  # public
      true
    else
      false
    end
  end

  def update?
    user && user.id == record.owner_id
  end

  def publish?
    update?
  end

  class Scope < Scope
    def resolve
      scope.where(status: 2).or(scope.where(owner_id: user.id, status: 1))
    end
  end
end
