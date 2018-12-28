class ChannelPolicy < ApplicationPolicy
  def show?
    record.public? || user.try(:id) == record.id
  end

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
