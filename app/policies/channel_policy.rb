class ChannelPolicy < ApplicationPolicy
  def publish?
    update?
  end

  def import?
    update?
  end

  class Scope < Scope
    def resolve
      scope.where(public: true).or(scope.where(user_id: user.id))
    end
  end
end
