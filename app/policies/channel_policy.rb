class ChannelPolicy < ApplicationPolicy
  def show?
    %w[public streaming].include?(record.status) || user.try(:id) == record.user_id
  end
end
