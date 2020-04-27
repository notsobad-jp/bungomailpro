class ChannelPolicy < ApplicationPolicy
  def show?
    update? || record.public?
  end
end
