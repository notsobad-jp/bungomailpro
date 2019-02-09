class ChannelsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :set_channel
  after_action :verify_authorized

  def index
    @channels = Channel.where(status: 'public')
    @breadcrumbs << { name: 'チャネル一覧' }
  end

  def show
    @subscription = current_user.subscriptions.find_by(channel_id: @channel.id) if current_user
    @finished = params[:books] == 'finished'

    @books = if @subscription
               @finished ? @subscription.finished_books : @subscription.scheduled_books
             else
               @channel.channel_books.map(&:book)
             end

    @meta_title = @channel.title
    @meta_description = @channel.description
    @meta_keywords = @channel.title
    @meta_noindex = @channel.private?

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
    @breadcrumbs << { name: @channel.title, url: channel_path(@channel.token) }
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
    if (token = params[:id])
      @channel = Channel.includes(channel_books: :book).find_by!(token: token)
      authorize @channel
    else
      authorize Channel
    end
  end
end
