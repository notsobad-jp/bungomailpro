class SubscriptionPolicy < ApplicationPolicy
  # streamingのときは、owner以外subscriptionの設定変更は不可
  def update?
    (user && user.id == record.user_id) && (!record.channel.streaming? || record == record.channel.master_subscription)
  end

  # destroyは streamingでも通常通り可能（デフォルトでupdate?と一緒なので上書きされないように再定義）
  def destroy?
    user && user.id == record.user_id
  end
end
