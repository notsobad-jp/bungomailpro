class MembershipsController < ApplicationController
  def new
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      mode: 'setup',
      customer_email: current_user.email,
      success_url: "#{completed_memberships_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: new_membership_url,
    )
    @meta_title = '決済情報の登録'
    @no_index = true
  end

  # Checkoutでの決済情報登録完了時のリダイレクトページ
  def completed
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    session = Stripe::Checkout::Session.retrieve({id: params[:session_id], expand: ['setup_intent']})

    cus = Stripe::Customer.create({
      email: current_user.email,
      payment_method: session.setup_intent.payment_method,
      invoice_settings: {default_payment_method: session.setup_intent.payment_method},
    })

    # sub = Stripe::Subscription.create({
    #   customer: cus.id,
    #   items: [ {price: ENV['STRIPE_PLAN_ID']} ],
    #   trial_end: current_user.membership.trial_end_at.since(1.second).to_i,
    # })
    beginning_of_next_month = Time.current.next_month.beginning_of_month
    # sub = Stripe::SubscriptionSchedule.create({
    #   customer: cus.id,
    #   start_date: beginning_of_next_month.to_i,
    #   end_behavior: 'release',
    #   phases: [
    #     {
    #       items: [ {price: ENV['STRIPE_PLAN_ID']} ],
    #       trial: true,
    #       iterations: 1,
    #     },
    #   ],
    # })
    sub = Stripe::SubscriptionSchedule.create({
      customer: cus.id,
      start_date: Time.current.since(5.minutes).to_i,
      end_behavior: 'release',
      phases: [
        {
          items: [ {price: ENV['STRIPE_PLAN_ID']} ],
          trial: true,
          end_date: Time.current.since(10.minutes).to_i,
        },
      ],
    })

    current_user.membership.update!(stripe_customer_id: cus.id, stripe_subscription_id: sub.id)
    current_user.membership.schedule_billing

    redirect_to(mypage_path, flash: { success: '決済処理が完了しました！翌月初から1ヶ月間の無料トライアルを開始し、翌々月から課金を開始します。' })
  rescue => e
    logger.error "[Error]Stripe subscription failed. #{e}"
    redirect_to(new_membership_path, flash: { error: '決済処理に失敗しました。。課金処理を中止したため、これにより支払いが発生することはありません。' })
  end
end
