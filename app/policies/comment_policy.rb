class CommentPolicy < ApplicationPolicy
  def update?
    user && user.id == record.subscription.user_id
  end
end
