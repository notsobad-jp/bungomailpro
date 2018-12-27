class ChannelBooksController < ApplicationController
  before_action :require_login
  before_action :authorize_channel_book, only: [:index, :new, :create]
  before_action :set_channel_book, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized


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

  def import
  end


  private
    def channel_book_params
      # params.require(:channel).permit(:title, :description, :deliver_at, :public, channel_books_attributes: [:id, :index, :book_id, :_destroy])
    end

    def set_channel_book
      # @channel = Channel.includes([channel_books: :book, next_chapter: :book, last_chapter: :book]).find_by!(token: params[:id])
      # authorize @channel
    end

    def authorize_channel_book
      authorize ChannelBook
    end
end
