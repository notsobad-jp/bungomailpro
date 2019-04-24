class UserPolicy < ApplicationPolicy
  def show?
    record.id == user.id
  end

  def pixela?
    record.id == user.id
  end
end
