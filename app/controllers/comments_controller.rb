class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_comment
  # after_action :verify_authorized

  def index
    book = @subscription.current_book
    index = @subscription.next_chapter_index
    range = index .. [index+31, book.chapters_count].min
    @comments = []
    range.each do |i|
      @comments << @subscription.comments.find_or_initialize_by(book_id: book.id, index: i)
    end

    @breadcrumbs << { name: '購読チャネル', url: subscriptions_path }
    @breadcrumbs << { name: @subscription.channel.title, url: channel_path(@subscription.channel) }
    @breadcrumbs << { name: 'コメント一覧' }
  end

  def show
  end

  def new
    @comment = @subscription.comments.new(book_id: params[:book_id], index: params[:index])

    @breadcrumbs << { name: '購読チャネル', url: subscriptions_path }
    @breadcrumbs << { name: @subscription.channel.title, url: channel_path(@subscription.channel) }
    @breadcrumbs << { name: 'コメント' }
  end

  def create
    @comment = @subscription.comments.new comment_params
    if @comment.save
      flash[:success] = 'コメントを保存しました🎉'
      redirect_to subscription_comments_path(@subscription)
    else
      render :new
    end
  end

  def edit
    @breadcrumbs << { name: '購読チャネル', url: subscriptions_path }
    @breadcrumbs << { name: @subscription.channel.title, url: channel_path(@subscription.channel) }
    @breadcrumbs << { name: 'コメント' }
  end

  def update
    if @comment.update(comment_params)
      flash[:success] = 'コメントを保存しました🎉'
      redirect_to subscription_comments_path(@subscription)
    else
      render :edit
    end
  end

  def destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:text, :book_id, :index)
  end

  def set_comment
    @subscription = Subscription.find(params[:subscription_id])
    authorize @subscription, :update?

    if params[:id]
      @comment = Comment.includes(chapter: :book).find(params[:id])
      authorize @comment
    end
  end
end
