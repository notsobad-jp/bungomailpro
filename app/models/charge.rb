# == Schema Information
#
# Table name: charges
#
#  id                                                                                            :string           not null, primary key
#  user_id                                                                                       :bigint(8)        not null
#  customer_id                                                                                   :string           not null
#  brand(IN (American Express, Diners Club, Discover, JCB, MasterCard, UnionPay, Visa, Unknown)) :string           not null
#  exp_month                                                                                     :integer          not null
#  exp_year                                                                                      :integer          not null
#  last4                                                                                         :string           not null
#  subscription_id                                                                               :string
#  status(IN (trialing active past_due canceled unpaid))                                         :string
#  trial_end                                                                                     :datetime
#  cancel_at                                                                                     :datetime
#  created_at                                                                                    :datetime         not null
#  updated_at                                                                                    :datetime         not null
#

class Charge < ApplicationRecord
  belongs_to :user
  TRIAL_PERIOD_DAYS = 31  # 無料トライアル日数
  BILLING_DAY = 5  # 毎月の決済日
  PLAN_ID = Rails.env.production? ? ENV['STRIPE_PLAN_ID'] : ENV['STRIPE_PLAN_ID_TEST']

  before_create do
    self.id = SecureRandom.hex(10)
  end



  def active?
    %w(trialing active past_due).include? self.status
  end


  def activate
    sub = Stripe::Subscription.retrieve(self.subscription_id)
    sub.cancel_at_period_end = false
    sub.save
    self.update(cancel_at: nil)
  end


  # 課金開始日の指定
  def billing_cycle_anchor
    next_payment_day = Time.current.next_month.beginning_of_month.change(day: BILLING_DAY)  # 基本は翌月5日から課金サイクル開始
    (self.trial_end > next_payment_day) ? next_payment_day.next_month : next_payment_day  # トライアル終了がそれ以降になる場合は、翌々月から課金サイクル開始
  end


  def cancel_subscription
    # 支払い失敗中の場合、すぐに解約する
    if self.status == 'past_due'
      sub = Stripe::Subscription.retrieve(self.subscription_id)
      sub.delete
      self.update(status: sub.status)
    # それ以外の場合は、期間終了時に解約予約
    else
      sub = Stripe::Subscription.retrieve(self.subscription_id)
      sub.cancel_at_period_end = true
      sub.save
      self.update(cancel_at: Time.zone.at(sub.cancel_at))
    end
  end


  def create_or_update_customer(params)
    # Stripe::Customerが登録されてなかったら新規登録、されてればクレカ情報更新（解約→再登録のケース）
    customer = Stripe::Customer.retrieve(self.customer_id) if self.persisted?
    if !customer
      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        source: params[:stripeToken]
      )
    # customerが存在する（解約→再登録）場合は、クレカ情報更新
    else
      customer.source = params[:stripeToken]
      customer.save
    end

    # DBにcharge情報保存
    card = customer.sources.first
    self.update_attributes(
      customer_id: customer.id,
      brand: card.brand,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      last4: card.last4
    )
  end


  def create_subscription
    raise 'already subscribing' if self.active?  # すでに支払い中の場合は処理を中断

    # Stripeでsubscription作成
    subscription = Stripe::Subscription.create(
      customer: self.customer_id,
      billing_cycle_anchor: self.billing_cycle_anchor.to_i,
      trial_end: self.trial_end.to_i,
      items: [{plan: PLAN_ID}]
    )

    # DBにsubscription情報を保存
    self.update!(
      subscription_id: subscription.id,
      status: subscription.status,
      trial_end: self.trial_end
    )
  end


  def trial_end
    TRIAL_PERIOD_DAYS.days.since(Time.current.end_of_day)
  end


  def update_customer(params)
    # Stripeでsourceを更新
    customer = Stripe::Customer.retrieve(self.customer_id)
    customer.source = params[:stripeToken]
    customer.save

    # DBにも更新を保存
    card = customer.sources.first
    self.update(
      brand: card.brand,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      last4: card.last4
    )
  end
end
