class UserPolicy < ApplicationPolicy
  def show?
    record.id == user.id
  end

  def update?
    user.try(:id) == record.id
  end
end
