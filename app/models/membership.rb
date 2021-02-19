class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  def schedule_trial
    ch_basic = Channel.find_by(code: 'bungomail-official')
    ch_free = Channel.find_by(code: 'dogramagra') # FIXME: 無料プラン用チャネル作ってそっちに差し替える

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      # トライアル開始時
      m_log_start = self.membership_logs.create!(plan: 'basic', status: "trialing", apply_at: beginning_of_next_month)
      m_log_start.subscription_logs.create!(user_id: self.id, channel_id: ch_basic.id, status: 'active', apply_at: beginning_of_next_month)

      # トライアル終了時
      m_log_cancel = self.membership_logs.create!(plan: 'free', status: "active", apply_at: end_of_next_month)
      m_log_cancel.subscription_logs.create!(user_id: self.id, channel_id: ch_basic.id, status: 'canceled', apply_at: end_of_next_month)
      m_log_cancel.subscription_logs.create!(user_id: self.id, channel_id: ch_free.id, status: 'active', apply_at: beginning_of_next_month.next_month, google_action: 'insert')  # 無料版はGoogleチャネルなのでgoogle_actionも追加
    end
  end

  # 決済情報登録して、翌月から課金開始
  def schedule_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.create!(plan: 'basic', status: "active", apply_at: beginning_of_next_month)
      self.membership_logs.scheduled.map(&:cancel)
    end
  end

  # 月末で解約してfreeプランに戻る
  def cancel_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.create!(plan: 'free', status: "active", apply_at: beginning_of_next_month)
      self.membership_logs.scheduled.map(&:cancel)
    end
  end

  # def active?
  #   %w[trialing active past_due].include? status
  # end
  #
  # def activate
  #   sub = Stripe::Subscription.retrieve(subscription_id)
  #   sub.cancel_at_period_end = false
  #   sub.save
  #   update(cancel_at: nil)
  # end
  #
  # def cancel_subscription
  #   # 支払い失敗中の場合、すぐに解約する
  #   if status == 'past_due'
  #     sub = Stripe::Subscription.retrieve(subscription_id)
  #     sub.delete
  #     update(status: sub.status)
  #   # それ以外の場合は、期間終了時に解約予約
  #   else
  #     sub = Stripe::Subscription.retrieve(subscription_id)
  #     sub.cancel_at_period_end = true
  #     sub.save
  #     update(cancel_at: Time.zone.at(sub.cancel_at))
  #   end
  # end
  #
  # def create_or_update_customer(params)
  #   # Stripe::Customerが登録されてなかったら新規登録、されてればクレカ情報更新（解約→再登録のケース）
  #   customer = Stripe::Customer.retrieve(customer_id) if customer_id.present?
  #   if !customer
  #     customer = Stripe::Customer.create(
  #       email: params[:stripeEmail],
  #       source: params[:stripeToken]
  #     )
  #   # customerが存在する（解約→再登録）場合は、クレカ情報更新
  #   else
  #     customer.source = params[:stripeToken]
  #     customer.save
  #   end
  #
  #   # DBにcharge情報保存
  #   card = customer.sources.first
  #   update(
  #     customer_id: customer.id,
  #     brand: card.brand,
  #     exp_month: card.exp_month,
  #     exp_year: card.exp_year,
  #     last4: card.last4
  #   )
  # end
  #
  # def create_subscription
  #   raise 'already subscribing' if active? # すでに支払い中の場合は処理を中断
  #
  #   if user.trial_end_at > Time.current
  #     # トライアル終了前なら、trial_endを終了日に設定
  #     billing_cycle_anchor = nil
  #     trial_end = user.trial_end_at
  #   else
  #     # トライアル終了後なら、trialなしでanchorを翌月初に設定
  #     billing_cycle_anchor = Time.current.next_month.beginning_of_month.to_i
  #     trial_end = nil
  #   end
  #
  #   # Stripeでsubscription作成
  #   subscription = Stripe::Subscription.create(
  #     customer: customer_id,
  #     trial_end: trial_end&.to_i,
  #     billing_cycle_anchor: billing_cycle_anchor,
  #     items: [{ plan: ENV['STRIPE_PLAN_ID'] }]
  #   )
  #
  #   # DBにsubscription情報を保存(chargeオブジェクトを返す）
  #   tap do |charge|
  #     charge.update!(
  #       subscription_id: subscription.id,
  #       status: subscription.status,
  #       trial_end: trial_end
  #     )
  #   end
  # end
  #
  # def update_customer(params)
  #   # Stripeでsourceを更新
  #   customer = Stripe::Customer.retrieve(customer_id)
  #   customer.source = params[:stripeToken]
  #   customer.save
  #
  #   # DBにも更新を保存
  #   card = customer.sources.first
  #   update(
  #     brand: card.brand,
  #     exp_month: card.exp_month,
  #     exp_year: card.exp_year,
  #     last4: card.last4
  #   )
  # end
end
