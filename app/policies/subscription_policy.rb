class SubscriptionPolicy < ApplicationPolicy
  def deliver?
    update?
  end

  def feed?
    true
  end

  def skip?
    update?
  end
end
