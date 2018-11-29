class SubscriptionsController < ApplicationController
  before_action :require_login
  before_action :authorize_subscription, only: [:index, :create]
  before_action :set_subscription, only: [:destroy, :update, :skip, :deliver, :show]
  after_action :verify_authorized

  def index
    @subscriptions = current_user.subscriptions.includes(:book)
  end

  def show
  end

  def create
    book_id = params[:book_id]
    current_index = current_user.subscriptions.maximum(:index) || 0
    @subscription = Subscription.new(user_id: current_user.id, book_id: book_id, index: current_index + 1)

    if @subscription.save
      flash[:success] = '配信リストに追加しました🎉'
      redirect_to subscriptions_path
    else
      p @subscription.errors
    end
  end

  def destroy
    course = @subscription.course
    @subscription.destroy
    redirect_to course
  end

  # 配信ステータスの変更（一時停止・再開）
  def update
    status = params[:status].to_i
    @subscription.update(status: status)

    # deliveriesの配信状況をアップデート
    if status == 1
      @subscription.restart
    elsif status == 2
      @subscription.pause
    end

    redirect_to @subscription
  end


  #FIXME: テスト配信メソッド
  def deliver
    @delivery = @subscription.deliveries.includes(:user, :book).where(delivered: false).order(:deliver_at).first
    @delivery.try(:deliver)
    flash[:success] = 'メールを配信しました！'
    redirect_to @subscription
  end


  private
    def set_subscription
      @subscription = Subscription.includes(:books).find(params[:id])
      authorize @subscription
    end

    def authorize_subscription
      authorize Subscription
    end
end
