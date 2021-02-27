class BookAssignmentPolicy < ApplicationPolicy
  # basicプラン && 自作チャネルへの配信予約
  def create?
    user && user.membership.plan == 'basic' && record.channel.user == user
  end
end
