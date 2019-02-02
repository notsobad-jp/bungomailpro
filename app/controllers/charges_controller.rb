class ChargesController < ApplicationController
  before_action :require_login
  before_action :set_charge
  after_action :verify_authorized

  def new
    redirect_to user_path(current_user.token) if current_user.charge

    @breadcrumbs << {name: 'アカウント情報', url: user_path(current_user.token)}
    @breadcrumbs << {name: '決済情報'}
  end


  def create
    # Stripe::Customerが登録されてなかったら新規登録、されてればクレカ情報更新（解約→再登録のケース）
    customer = Stripe::Customer.retrieve(current_user.charge.customer_id) if current_user.charge.present?
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
    charge = Charge.find_or_initialize_by(user_id: current_user.id)
    charge.update_attributes(
      customer_id: customer.id,
      brand: card.brand,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      last4: card.last4
    )

    # すでに支払い中の場合は処理を中断
    if %w(trialing active).include? charge.status
      flash[:warning] = 'すでに支払いが登録されているため、新たな支払いの登録をキャンセルしました。心当たりがない場合は運営までお問い合わせください。'
      return redirect_to user_path(current_user.token)
    end

    # 定期課金開始
    next_payment_day = Time.current.next_month.beginning_of_month.change(day: 5)  # 翌月5日から課金サイクル開始
    trial_end = 31.days.since(Time.current.end_of_day)  # トライアル: 31日間
    next_payment_day = next_payment_day.next_month if trial_end > next_payment_day  # トライアル終了が31日以上後になる場合は、翌々月から課金サイクル開始

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      billing_cycle_anchor: next_payment_day.to_i,
      trial_end: trial_end.to_i,
      items: [{plan: ENV['STRIPE_PLAN_ID']}]
    )
    charge.update!(
      subscription_id: subscription.id,
      status: subscription.status,
      trial_end: trial_end
    )

    flash[:success] = '決済登録が完了しました🎉 1ヶ月の無料トライアル期間のあとに、支払いが開始します'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    Logger.new(STDOUT).error "[STRIPE CREATE] user: #{current_user.id}, error: #{e}"
    flash[:error] = '決済情報の登録に失敗しました...。カード情報を再度ご確認のうえ、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to new_charge_path
  end


  def edit
    @breadcrumbs << {name: 'アカウント情報', url: user_path(current_user.token)}
    @breadcrumbs << {name: '決済情報の更新'}
  end


  def update
    customer = Stripe::Customer.retrieve(@charge.customer_id)
    customer.source = params[:stripeToken]
    customer.save

    card = customer.sources.first
    @charge.update(
      brand: card.brand,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      last4: card.last4
    )

    flash[:success] = 'カード情報を更新しました🎉 次回の支払いから変更が適用されます。'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    Logger.new(STDOUT).error "[STRIPE UPDATE] user: #{current_user.id}, error: #{e}"
    flash[:error] = 'カード情報の更新に失敗しました...。カード情報を再度ご確認のうえ、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to edit_charge_path(@charge)
  end


  def destroy
    sub = Stripe::Subscription.retrieve(@charge.subscription_id)
    sub.cancel_at_period_end = true
    sub.save
    @charge.update(cancel_at: Time.zone.at(sub.cancel_at))

    flash[:info] = '解約を受け付けました。これ以降の支払いは一切行われません。メール配信は次回決済日の前日まで継続したあと、自動的に終了します。すぐに配信も停止したい場合は、チャネルの購読を解除してください。ご利用ありがとうございました。'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    Logger.new(STDOUT).error "[STRIPE DESTROY] user: #{current_user.id}, error: #{e}"
    flash[:error] = '決済登録の解除に失敗しました...。画面をリロードして、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to user_path(current_user.token)
  end


  # 解約予約したのを再度アクティベイト
  def activate
    sub = Stripe::Subscription.retrieve(@charge.subscription_id)
    sub.cancel_at_period_end = false
    sub.save
    @charge.update(cancel_at: nil)

    flash[:info] = '解約を取り消しました。次回決済日から通常どおり支払いが行われます。'
    redirect_to user_path(current_user.token)
  end


  # Stripe自動送信メール用の支払い情報更新リンク: charges#editにリダイレクトする
  def update_payment
    if charge = current_user.charge
      redirect_to edit_charge_path(charge)
    else
      redirect_to user_path(current_user.token)
    end
  end


  private
    def set_charge
      if id = params[:id]
        @charge = Charge.find(id)
        authorize @charge
      else
        authorize Charge
      end
    end
end
