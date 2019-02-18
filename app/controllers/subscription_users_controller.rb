class SubscriptionUsersController < ApplicationController
  before_action :require_login
  before_action :set_subscription
  after_action :verify_authorized

  def create
    if @subscription.add_user(current_user)
      flash[:success] = "チャネルを購読しました🎉 #{@subscription.next_delivery_date.strftime("%-m月%-d日")}から配信が開始します。"
    else
      flash[:error] = "チャネルの購読に失敗しました...再度試してもうまくいかない場合、運営までお問い合わせください。"
    end
    redirect_to channel_path(@subscription.channel)
  end

  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
    authorize @subscription, :show?
  end
end
