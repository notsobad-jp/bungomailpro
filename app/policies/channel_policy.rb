class ChannelPolicy < ApplicationPolicy
  def show?
    record.public? || user.try(:id) == record.user_id
  end

  class Scope < Scope
    def resolve
      scope.where(public: true).or(scope.where(user_id: user.id))
    end
  end
end
