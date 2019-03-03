class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_comment
  # after_action :verify_authorized

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end

  def set_comment
    @subscription = Subscription.find(params[:subscription_id])
    if params[:id]
      @comment = Comment.includes(chapter: :book).find(params[:id])
      authorize @subscription
      authorize @comment
    else
      authorize @subscription
      authorize Comment
    end
  end
end
