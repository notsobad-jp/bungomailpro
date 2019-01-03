class SubscriptionsController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :authorize_subscription, only: [:index, :create]
  before_action :set_subscription, only: [:destroy, :update, :show, :edit]
  after_action :verify_authorized

  def index
    # 作成直後でまだ購読してないchannelも表示する
    @draft_channels = current_user.channels.where(subscribers_count: 0)
    @subscriptions = current_user.subscriptions.includes(:channel, next_chapter: :book, last_chapter: :book) if current_user
  end

  def create
    @channel = Channel.find_by(token: params[:channel_id])
    @channel.subscriptions.create!(
      user_id: current_user.id,
      next_delivery_date: Time.zone.tomorrow,
      next_chapter_id: @channel.next_book.first_chapter.id
    )
    flash[:success] = 'チャネルの配信を開始しました🎉 翌日からメール配信が始まります。'
    redirect_to channel_path(@channel.token)
  end


  private
    def authorize_subscription
      authorize Subscription
    end

    def set_subscription
      @subscription = Subscription.includes(:channel).find(params[:id])
      authorize @subscription
    end
end
