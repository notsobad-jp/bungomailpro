class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id

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
    customer = Stripe::Customer.retrieve(customer_id) if customer_id.present?
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

    if user.trial_end_at > Time.current
      # トライアル終了前なら、trial_endを終了日に設定
      billing_cycle_anchor = nil
      trial_end = user.trial_end_at
    else
      # トライアル終了後なら、trialなしでanchorを翌月初に設定
      billing_cycle_anchor = Time.current.next_month.beginning_of_month.to_i
      trial_end = nil
    end

    # Stripeでsubscription作成
    subscription = Stripe::Subscription.create(
      customer: customer_id,
      trial_end: trial_end&.to_i,
      billing_cycle_anchor: billing_cycle_anchor,
      items: [{ plan: ENV['STRIPE_PLAN_ID'] }]
    )

    # DBにsubscription情報を保存(chargeオブジェクトを返す）
    tap do |charge|
      charge.update!(
        subscription_id: subscription.id,
        status: subscription.status,
        trial_end: trial_end
      )
    end
  end

  # Subscriptionに紐づく最新の支払い（支払い済み && リファンドしてない場合のみ）
  ## Stripe::Chargeオブジェクトを返す
  def latest_payment
    invoice = Stripe::Subscription.retrieve({id: subscription_id, expand: ['latest_invoice.charge']}).latest_invoice
    invoice.charge if invoice.paid && invoice.charge&.paid && !invoice.charge.refunded
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

  # 直近で支払ったchargeをrefundする
  def refund_latest_payment
    raise 'no payment exists' if (payment = latest_payment).blank?
    Stripe::Refund.create({charge: payment.id})
  end
end
