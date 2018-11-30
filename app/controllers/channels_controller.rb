class ChannelsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :authorize_channel, only: [:index, :new, :create, :owned]
  before_action :set_channel_with_books, only: [:show, :edit, :update, :publish, :destroy, :add_book]
  after_action :verify_authorized


  def index
    @channels = Channel.where(status: 2)
  end

  def show
    @subscription = current_user.subscriptions.find_by(channel_id: @channel.id) if current_user
  end

  def new
    @channel = Channel.new
  end

  def edit
  end

  def create
    @channel = Channel.new channel_params
    @channel.user_id = current_user.id

    if @channel.save
      flash[:success] = 'チャネルを作成しました🎉'
      redirect_to owned_channels_path
    else
      render :new
    end
  end

  def update
    if @channel.update(channel_params)
      flash[:success] = '変更を保存しました🎉'
      redirect_to owned_channels_path
    else
      render :edit
    end
  end

  def publish
    if @channel.publish
      flash[:success] = 'チャネルの配信を開始しました🎉翌日からメール配信が始まります。'
    else
      flash[:error] = '配信開始できませんでした..😢チャネルに本が登録されているか確認してください。'
    end
    redirect_to subscriptions_path
  end

  #TODO
  def destroy
    @channel.update(status: 3)
    flash[:success] = 'コースを削除しました'
    redirect_to owned_channels_path
  end

  #TODO
  def owned
    @channels = policy_scope current_user.own_channels
  end

  def add_book
    @book = Book.find(params[:book_id])
    return if @channel.channel_books.find_by(book_id: @book.id) || !@book

    current_index = @channel.channel_books.maximum(:index) || 0

    course_book = @channel.channel_books.new(book_id: @book.id, index: current_index + 1)
    if course_book.save
      return true
    else
      p course_book.errors
      return false
    end
  end


  private
    def channel_params
      params.require(:channel).permit(:title, :description, channel_books_attributes: [:id, :index, :book_id, :_destroy])
    end

    def set_channel_with_books
      @channel = Channel.includes(channel_books: :book).find(params[:id])
      authorize @channel
    end

    def authorize_channel
      authorize Channel
    end
end
