class ChargesController < ApplicationController
  before_action :require_login
  before_action :set_charge
  after_action :verify_authorized

  def new
    # TODO: policyに権限制御を移動する（createにも同じのを追加）
    redirect_to user_path(current_user.token) if current_user.charge && current_user.charge.status != 'canceled'

    @breadcrumbs << {name: 'アカウント情報', url: user_path(current_user.token)}
    @breadcrumbs << {name: '決済情報'}
  end


  def create
    # Stripe::Customerが登録されてなかったら新規登録、されてればクレカ情報更新（解約→再登録のケース）
    charge = Charge.find_or_initialize_by(user_id: current_user.id)
    charge.create_or_update_customer(params)

    # 定期課金開始
    charge.create_subscription

    flash[:success] = '決済登録が完了しました🎉 1ヶ月の無料トライアル期間のあとに、支払いが開始します'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    logger.error "[STRIPE CREATE] user: #{current_user.id}, error: #{e}"
    flash[:error] = '決済情報の登録に失敗しました...。カード情報を再度ご確認のうえ、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to new_charge_path
  end


  def edit
    @breadcrumbs << {name: 'アカウント情報', url: user_path(current_user.token)}
    @breadcrumbs << {name: '決済情報の更新'}
  end


  def update
    @charge.update_customer(params)

    flash[:success] = 'カード情報を更新しました🎉 次回の支払いから変更が適用されます。'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    Logger.new(STDOUT).error "[STRIPE UPDATE] user: #{current_user.id}, error: #{e}"
    flash[:error] = 'カード情報の更新に失敗しました...。カード情報を再度ご確認のうえ、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to edit_charge_path(@charge)
  end


  def destroy
    @charge.cancel_subscription

    flash[:info] = '解約を受け付けました。これ以降の支払いは一切行われません。メール配信は次回決済日の前日まで継続したあと、自動的に終了します。すぐに配信も停止したい場合は、チャネルの購読を解除してください。ご利用ありがとうございました。'
    redirect_to user_path(current_user.token)
  rescue Stripe::CardError => e
    Logger.new(STDOUT).error "[STRIPE DESTROY] user: #{current_user.id}, error: #{e}"
    flash[:error] = '決済登録の解除に失敗しました...。画面をリロードして、しばらく経ってからもう一度お試しください。どうしてもうまくいかない場合は運営までお問い合わせください。'
    redirect_to user_path(current_user.token)
  end


  # 解約予約したのを再度アクティベイト
  def activate
    @charge.activate

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
