class SubscriptionPolicy < ApplicationPolicy
  def deliver?
    update?
  end

  def skip?
    update?
  end
end
