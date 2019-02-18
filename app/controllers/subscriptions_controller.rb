require 'rss'

class SubscriptionsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :set_subscription
  after_action :verify_authorized

  def index
    if current_user
      @finished = params[:q] == 'finished'
      query = current_user.subscriptions.includes(:channel, :next_chapter, :current_book)
      @subscriptions = @finished ? query.where(current_book_id: nil) : query.where.not(current_book_id: nil)
      @draft_channels = current_user.channels.where(subscribers_count: 0) unless @finished
    end
    @breadcrumbs << { name: '購読チャネル' }
  end

  def edit
    @breadcrumbs << { name: '購読チャネル', url: subscriptions_path }
    @breadcrumbs << { name: @channel.title, url: channel_path(@channel) }
    @breadcrumbs << { name: '配信設定' }
  end

  def show
    respond_to do |format|
      format.atom
    end
  end

  def update
    if @subscription.update(subscription_params)
      flash[:success] = '変更を保存しました🎉 配信時間の変更は翌日の配信から反映されます。'
      redirect_to channel_path(@channel)
    else
      render :edit
    end
  end

  def create
    @channel = Channel.find(params[:channel_id])
    begin
      @subscription = current_user.subscribe(@channel)
      next_delivery_date = @channel.streaming? ? @channel.master_subscription.next_delivery_date.strftime("%-m月%-d日") : "翌日"
      flash[:success] = "チャネルの配信を開始しました🎉 #{ next_delivery_date }からメール配信が始まります。"
      redirect_to channel_path(@channel)
    rescue StandardError
      flash[:error] = '配信開始できませんでした😢 購読チャネル数の上限を超える場合は、他のチャネルを解除してからお試しください。'
      redirect_to request.referer || pro_root_path
    end
  end

  def destroy
    @subscription.destroy
    flash[:success] = '配信を解除しました。すでに配信予約済みのメールは翌日も届く場合があります。ご了承ください。'

    redirect_to channel_path(@channel)
  end

  private

  def subscription_params
    params.require(:subscription).permit(:delivery_hour, :next_delivery_date)
  end

  def set_subscription
    if params[:id]
      @subscription = Subscription.includes(:channel).find(params[:id])
      @channel = @subscription.channel
      authorize @subscription
    else
      authorize Subscription
    end
  end
end
