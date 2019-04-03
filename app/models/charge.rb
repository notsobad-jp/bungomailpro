# == Schema Information
#
# Table name: charges
#
#  id                                                                                            :uuid             not null, primary key
#  brand(IN (American Express, Diners Club, Discover, JCB, MasterCard, UnionPay, Visa, Unknown)) :string           not null
#  cancel_at                                                                                     :datetime
#  exp_month                                                                                     :integer          not null
#  exp_year                                                                                      :integer          not null
#  last4                                                                                         :string           not null
#  status(IN (trialing active past_due canceled unpaid))                                         :string
#  trial_end                                                                                     :datetime
#  created_at                                                                                    :datetime         not null
#  updated_at                                                                                    :datetime         not null
#  customer_id                                                                                   :string           not null
#  subscription_id                                                                               :string
#  user_id                                                                                       :uuid             not null
#
# Indexes
#
#  index_charges_on_customer_id      (customer_id) UNIQUE
#  index_charges_on_subscription_id  (subscription_id) UNIQUE
#  index_charges_on_user_id          (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Charge < ApplicationRecord
  belongs_to :user
  TRIAL_PERIOD_DAYS = 14 # 無料トライアル日数
  BILLING_DAY = 5 # 毎月の決済日

  def active?
    %w[trialing active past_due].include? status
  end

  def activate
    sub = Stripe::Subscription.retrieve(subscription_id)
    sub.cancel_at_period_end = false
    sub.save
    update(cancel_at: nil)
  end

  # 課金開始日の指定
  def billing_cycle_anchor
    next_payment_day = Time.current.next_month.beginning_of_month.change(day: BILLING_DAY) # 基本は翌月5日から課金サイクル開始
    trial_end_at > next_payment_day ? next_payment_day.next_month : next_payment_day # トライアル終了がそれ以降になる場合は、翌々月から課金サイクル開始
  end

  def cancel_subscription
    # 支払い失敗中の場合、すぐに解約する
    if status == 'past_due'
      sub = Stripe::Subscription.retrieve(subscription_id)
      sub.delete
      update(status: sub.status)
    # それ以外の場合は、期間終了時に解約予約
    else
      sub = Stripe::Subscription.retrieve(subscription_id)
      sub.cancel_at_period_end = true
      sub.save
      update(cancel_at: Time.zone.at(sub.cancel_at))
    end
  end

  def create_or_update_customer(params)
    # Stripe::Customerが登録されてなかったら新規登録、されてればクレカ情報更新（解約→再登録のケース）
    customer = Stripe::Customer.retrieve(customer_id) if persisted?
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
    update(
      customer_id: customer.id,
      brand: card.brand,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      last4: card.last4
    )
  end

  def create_subscription
    raise 'already subscribing' if active? # すでに支払い中の場合は処理を中断

    # Stripeでsubscription作成
    subscription = Stripe::Subscription.create(
      customer: customer_id,
      billing_cycle_anchor: billing_cycle_anchor.to_i,
      trial_end: trial_end_at.to_i,
      items: [{ plan: ENV['STRIPE_PLAN_ID'] }]
    )

    # DBにsubscription情報を保存
    update!(
      subscription_id: subscription.id,
      status: subscription.status,
      trial_end: trial_end_at
    )
  end

  def trial_end_at
    TRIAL_PERIOD_DAYS.days.since(Time.current.end_of_day)
  end

  def update_customer(params)
    # Stripeでsourceを更新
    customer = Stripe::Customer.retrieve(customer_id)
    customer.source = params[:stripeToken]
    customer.save

    # DBにも更新を保存
    card = customer.sources.first
    update(
      brand: card.brand,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      last4: card.last4
    )
  end
end
