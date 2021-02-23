class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  def schedule_trial
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      # トライアル開始時
      m_log_start = self.membership_logs.create!(plan: 'basic', status: "trialing", apply_at: Time.current.next_month.beginning_of_month)
      m_log_start.subscription_logs.create!(user_id: self.id, channel_id: Channel::OFFICIAL_CHANNEL_ID, status: 'active', apply_at: Time.current.next_month.beginning_of_month)

      # トライアル終了時
      m_log_cancel = self.membership_logs.create!(plan: 'free', status: "active", apply_at: Time.current.next_month.end_of_month)
      m_log_cancel.subscription_logs.create!(user_id: self.id, channel_id: Channel::OFFICIAL_CHANNEL_ID, status: 'canceled', apply_at: Time.current.next_month.end_of_month)

      # TODO: 無料じゃないチャネルの購読をすべて解除 & 予約してるのも削除
    end
  end

  # 決済情報登録して、翌月から課金開始
  def schedule_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.scheduled.map(&:cancel)
      self.membership_logs.create!(plan: 'basic', status: "active", apply_at: Time.current.next_month.beginning_of_month)
    end
  end

  # 月末で解約してfreeプランに戻る
  def cancel_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.scheduled.map(&:cancel)
      self.membership_logs.create!(plan: 'free', status: "active", apply_at: Time.current.next_month.beginning_of_month)

      # TODO: 無料じゃないチャネルの購読をすべて解除 & 予約してるのも削除
    end
  end
end
