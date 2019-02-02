class ChargePolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end

  def activate?
    update?
  end
end
