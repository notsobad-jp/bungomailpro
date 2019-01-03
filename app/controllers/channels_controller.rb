class ChannelsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :authorize_channel, only: [:index, :new, :create]
  before_action :set_channel_with_books, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized


  def index
    @channels = Channel.where(public: true)
  end

  def show
    @subscription = current_user.subscriptions.find_by(channel_id: @channel.id) if current_user
    @finished = params[:books] == 'finished'
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

  def publish
    if @channel.publish
      flash[:success] = 'チャネルの配信を開始しました🎉翌日からメール配信が始まります。'
    else
      flash[:error] = '配信開始できませんでした..😢チャネルに本が登録されているか確認してください。'
    end
    redirect_to subscriptions_path
  end

  def import
    from_channel = Channel.find_by(token: params[:from_channel_id])
    if @channel.import(from_channel)
      flash[:success] = "#{@channel.title}に#{from_channel.books_count}冊の作品をインポートしました🎉（登録済みの本はスキップされています）"
    else
      flash[:error] = 'インポートに失敗しました..😢 再度試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path from_channel.token
  end


  private
    def channel_params
      params.require(:channel).permit(:title, :description, :deliver_at, :public, channel_books_attributes: [:id, :index, :book_id, :_destroy])
    end

    def set_channel_with_books
      @channel = Channel.includes(channel_books: :book).find_by!(token: params[:id])
      authorize @channel
    end

    def authorize_channel
      authorize Channel
    end
end
