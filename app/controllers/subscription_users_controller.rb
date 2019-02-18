class SubscriptionUsersController < ApplicationController
  before_action :require_login
  after_action :verify_authorized

  def create
    @subscription = Subscription.find(params[:subscription_id])
    authorize @subscription, :show?

    if @subscription.add_user(current_user)
      flash[:success] = "チャネルを購読しました🎉 #{@subscription.next_delivery_date.strftime("%-m月%-d日")}から配信が開始します。"
    else
      flash[:error] = "チャネルの購読に失敗しました...再度試してもうまくいかない場合、運営までお問い合わせください。"
    end
    redirect_to channel_path(@subscription.channel)
  end

  def destroy
    @sub_user = SubscriptionUser.find_by!(subscription_id: params[:subscription_id], user_id: current_user.id)
    authorize @sub_user

    @sub_user.destroy
    flash[:success] = '配信を解除しました。すでに配信予約済みのメールは翌日も届く場合があります。ご了承ください。'

    redirect_to channel_path(@sub_user.subscription.channel_id)
  end
end
