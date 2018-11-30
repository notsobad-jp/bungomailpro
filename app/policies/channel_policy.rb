class ChannelPolicy < ApplicationPolicy
  def show?
    update?
  end

  def publish?
    update?
  end

  def owned?
    create?
  end

  def add_book?
    update?
  end

  class Scope < Scope
    def resolve
      scope.where(public: true).or(scope.where(user_id: user.id))
    end
  end
end
