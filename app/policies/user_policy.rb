class UserPolicy < ApplicationPolicy
  # userのみ、recordのuser_idじゃなくてidと比較
  def update?
    user && user.id == record.id
  end
end
