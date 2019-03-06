class CommentPolicy < ApplicationPolicy
  def create?
    user && user.id == record.subscription.user_id
  end

  def update?
    user && user.id == record.subscription.user_id
  end
end
