class UserPolicy < ApplicationPolicy
  def show?
    record.id == user.id
  end

  def update?
    user && user.id == record.id
  end
end
