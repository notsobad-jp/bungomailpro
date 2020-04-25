class ChannelPolicy < ApplicationPolicy
  def show?
    update? || record.public?
  end

  def destroy?
    update? && !record.default?
  end
end
