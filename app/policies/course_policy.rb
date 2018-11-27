class CoursePolicy < ApplicationPolicy
  def show?
    if record.draft?
      user.id == record.owner_id
    else
      true
    end
  end

  def update?
    user && user.id == record.owner_id
  end

  def publish?
    update?
  end

  def owned?
    create?
  end

  def books?
    show?
  end

  class Scope < Scope
    def resolve
      scope.where(status: 2).or(scope.where(owner_id: user.id, status: 1))
    end
  end
end
