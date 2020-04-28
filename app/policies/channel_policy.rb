class ChannelPolicy < ApplicationPolicy
  def show?
    update? || record.public?
  end

  def add_books?
    update?
  end
end
