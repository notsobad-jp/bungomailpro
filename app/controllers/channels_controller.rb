class ChannelsController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper

  before_action :require_login, except: %i[index show]
  before_action :set_channel
  after_action :verify_authorized

  def index
    @channels = Channel.where(status: 'public')
    @breadcrumbs << { name: 'チャネル一覧' }
  end

  def show
    # streamingの場合は、オーナーのsubscriptionで共通の配信状況を見る
    @subscription = current_user.subscriptions.find_by(channel_id: @channel.id) if current_user
    @master_sub = @channel.master_subscription

    @finished = params[:books] == 'finished'
    sub = @channel.streaming? ? @channel.master_subscription : @subscription
    @books = if sub
               @finished ? sub.finished_books : sub.scheduled_books
             else
               @channel.channel_books.map(&:book)
             end

    @meta_title = @channel.title
    @meta_description = @channel.description.truncate(300)
    @meta_keywords = @channel.title
    @meta_noindex = @channel.private?
    @meta_image = image_url("/assets/images/channels/#{@channel.id}.jpg") if @channel.streaming?

    @breadcrumbs << { name: '購読チャネル', url: subscriptions_path }
    @breadcrumbs << { name: @channel.title }
  end

  def new
    @channel = Channel.new

    @breadcrumbs << { name: '購読チャネル', url: subscriptions_path }
    @breadcrumbs << { name: 'チャネル作成' }
  end

  def edit
    @breadcrumbs << { name: '購読チャネル', url: subscriptions_path }
    @breadcrumbs << { name: @channel.title, url: channel_path(@channel) }
    @breadcrumbs << { name: '編集' }
  end

  def create
    @channel = Channel.new channel_params
    @channel.user_id = current_user.id

    if @channel.save
      flash[:success] = 'チャネルを作成しました🎉'
      redirect_to subscriptions_path
    else
      render :new
    end
  end

  def update
    if @channel.update(channel_params)
      flash[:success] = '変更を保存しました🎉'
      redirect_to subscriptions_path
    else
      render :edit
    end
  end

  def destroy
    @channel.destroy
    flash[:success] = 'チャネルを削除しました'

    redirect_to subscriptions_path
  end

  private

  def channel_params
    params.require(:channel).permit(:title, :description, :status, :default, channel_books_attributes: %i[id index book_id _destroy])
  end

  def set_channel
    if params[:id]
      @channel = Channel.includes(channel_books: :book).find(params[:id])
      authorize @channel
    else
      authorize Channel
    end
  end
end
