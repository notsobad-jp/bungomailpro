class UserPolicy < ApplicationPolicy
  # userのみ、recordのuser_idじゃなくてidと比較
  def update?
    user && user.id == record.id
  end

  def start_trial_now?
    update?
  end
end
