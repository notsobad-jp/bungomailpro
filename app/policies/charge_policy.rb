class ChargePolicy < ApplicationPolicy
  def show?
    record.id == user.id
  end
end
