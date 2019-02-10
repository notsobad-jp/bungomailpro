class ChannelPolicy < ApplicationPolicy
  def show?
    !record.private? || user.try(:id) == record.user_id
  end
end
