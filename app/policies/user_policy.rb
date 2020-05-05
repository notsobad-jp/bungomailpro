class UserPolicy < ApplicationPolicy
  # userのみ、recordのuser_idじゃなくてidと比較
  def update?
    user && user.id == record.id
  end

  def start_trial_now?
    # トライアル開始前
    update? && record.before_trial?
  end

  def pause_subscription?
    # トライアル終了済み && 配信中
    update? && record.trial_end_at < Time.current && record.list_subscribed?
  end
end
