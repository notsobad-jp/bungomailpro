class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  enum status: { active: 1, trialing: 2, canceled: 3 }

  def schedule_trial
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.create!(plan: 'basic', status: :trialing, apply_at: Time.current.next_month.beginning_of_month)
      self.membership_logs.create!(plan: 'free', status: :active, apply_at: Time.current.next_month.end_of_month)
    end
  end

  # 決済情報登録して、翌月から課金開始
  def schedule_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.scheduled.update_all(canceled: true)
      self.membership_logs.create!(plan: 'basic', status: :active, apply_at: Time.current.next_month.beginning_of_month)
    end
  end

  # 月末で解約してfreeプランに戻る
  def cancel_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.scheduled.update_all(canceled: true)
      self.membership_logs.create!(plan: 'free', status: :active, apply_at: Time.current.next_month.beginning_of_month)
    end
  end
end
