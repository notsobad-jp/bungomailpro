require 'rss'

class SubscriptionsController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :authorize_subscription, only: [:index, :create]
  before_action :set_subscription, only: [:destroy, :update, :show, :edit]
  after_action :verify_authorized

  def index
    if current_user
      # 作成直後でまだ購読してないchannelも表示する
      @draft_channels = current_user.channels.where(subscribers_count: 0)
      @subscriptions = current_user.subscriptions.includes(:channel, :next_chapter, :current_book)
    end
  end

  def edit
  end

  def feed
    subscription = Subscription.includes(:channel, feeds: [:book, :chapter]).find_by(token: params[:id])
    authorize subscription

    rss = RSS::Maker.make("atom") do |feed|
      feed.channel.title = subscription.channel.title
      feed.channel.author = 'ブンゴウメール'
      feed.channel.updated = subscription.feeds.first.try(:delivered_at).try(:to_s) || subscription.created_at.to_s
      feed.channel.about = subscription_url(subscription.token)

      subscription.feeds.each do |entry|
        feed.items.new_item do |item|
          item.id = "#{entry.book_id}-#{entry.index}"
          item.title = "#{entry.book.title}（#{entry.chapter.index}/#{entry.book.chapters_count}）"
          item.updated = entry.delivered_at.to_s
          item.author = entry.book.author
          item.description = view_context.simple_format entry.chapter.text
        end
      end
    end

    render xml: rss.to_s
  end

  def update
    if @subscription.update(subscription_params)
      flash[:success] = '変更を保存しました🎉 配信時間の変更は翌日の配信から反映されます。'
      redirect_to channel_path(@channel.token)
    else
      render :edit
    end
  end

  def create
    @channel = Channel.find_by(token: params[:channel_id])
    current_user.subscribe(@channel)

    flash[:success] = 'チャネルの配信を開始しました🎉 翌日からメール配信が始まります。'
    redirect_to channel_path(@channel.token)
  end

  def destroy
    @subscription.destroy
    flash[:success] = '配信を解除しました。すでに配信予約済みのメールは翌日も届く場合があります。ご了承ください。'

    redirect_to channel_path(@channel.token)
  end


  private
    def subscription_params
      params.require(:subscription).permit(:delivery_hour)
    end

    def authorize_subscription
      authorize Subscription
    end

    def set_subscription
      @subscription = Subscription.includes(:channel).find_by(token: params[:id])
      @channel = @subscription.channel
      authorize @subscription
    end
end
