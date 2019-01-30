class ChargesController < ApplicationController
  before_action :require_login

  def new
    @breadcrumbs << {name: 'アカウント情報', url: user_path(current_user.token)}
    @breadcrumbs << {name: '決済情報'}
  end


  def create
    # Stripe::Customerが登録されてなかったら新規登録、されてれば情報取得
    customer = Stripe::Customer.retrieve(current_user.charge.customer_id) if current_user.charge.present?
    if !customer
      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        source: params[:stripeToken]
      )
      current_user.create_charge(customer_id: customer.id)
    end

    # すでに支払い中の場合は処理を中断
    if %w(trialing active).include? current_user.charge.status
      flash[:warning] = 'すでに支払いが登録されているため、新たな支払いの登録をキャンセルしました。心当たりがない場合は運営までお問い合わせください。'
      return redirect_to user_path(current_user.token)
    end

    # 定期課金開始
    next_payment_day = Time.current.next_month.beginning_of_month.change(day: 5)  # 翌月5日から課金サイクル開始
    trial_end = 31.days.since(Time.current)  # トライアル: 31日間
    next_payment_day = next_payment_day.next_month if trial_end > next_payment_day  # トライアル終了が31日以上後になる場合は、翌々月から課金サイクル開始

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      billing_cycle_anchor: next_payment_day.to_i,
      trial_end: trial_end.to_i,
      items: [{plan: ENV['STRIPE_PLAN_ID']}]
    )
    current_user.charge.update!(
      subscription_id: subscription.id,
      status: subscription.status,
      trial_end: trial_end
    )

    flash[:success] = '決済登録が完了しました🎉 1ヶ月の無料トライアル期間のあとに、支払いが開始します'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end


  def edit
    @charge = Charge.find(params[:id])
    @breadcrumbs << {name: 'アカウント情報', url: user_path(current_user.token)}
    @breadcrumbs << {name: '決済情報の更新'}
  end


  def update
    @charge = Charge.find(params[:id])
  end


  def destroy
    @charge = Charge.find(params[:id])
    sub = Stripe::Subscription.retrieve(@charge.subscription_id)
    sub = sub.delete
    @charge.update!(status: sub.status)

    flash[:info] = '登録を解除しました。これ以降の支払いは行われません。メール配信は翌日から停止します。ご利用ありがとうございました。'
    redirect_to user_path(current_user.token)
  end
end
