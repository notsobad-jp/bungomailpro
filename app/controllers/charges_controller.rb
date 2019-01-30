class ChargesController < ApplicationController
  before_action :require_login

  def new
  end

  def create
    # Stripe::Customerが登録されてなかったら新規登録、されてれば情報取得
    customer = Stripe::Customer.retrieve(current_user.stripe_customer_id) if current_user.stripe_customer_id
    if !customer
      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        source: params[:stripeToken]
      )
      current_user.update(stripe_customer_id: customer.id)
    end

    # すでに支払い中の場合は処理を中断
    subscribed = Stripe::Subscription.list(limit: 1, customer: customer.id).data.present?
    if subscribed
      flash[:warning] = 'すでに支払いが登録されているため、新たな支払いの登録をキャンセルしました。心当たりがない場合は運営までお問い合わせください。'
      return redirect_to user_path(current_user.token)
    end

    # 定期課金開始
    Stripe::Subscription.create(
      customer: customer.id,
      items: [{plan: ENV['STRIPE_PLAN_ID']}]
    )
    flash[:success] = '決済登録が完了しました🎉 1ヶ月の無料期間のあと、支払いを開始します。'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
end
