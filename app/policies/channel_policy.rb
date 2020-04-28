class ChannelPolicy < ApplicationPolicy
  def show?
    update? || record.public?
  end

  def add_books?
    update?
  end

  def start?
    update?
  end
  
  def pause?
    update?
  end
end
