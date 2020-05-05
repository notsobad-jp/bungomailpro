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

  def active?
    %w[trialing active past_due].include? status
  end

  def activate
    sub = Stripe::Subscription.retrieve(subscription_id)
    sub.cancel_at_period_end = false
    sub.save
    update(cancel_at: nil)
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
      trial_end: user.trial_end_at.to_i,
      items: [{ plan: ENV['STRIPE_PLAN_ID'] }]
    )

    # DBにsubscription情報を保存
    update!(
      subscription_id: subscription.id,
      status: subscription.status,
      trial_end: user.trial_end_at
    )
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
