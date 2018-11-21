class SubscriptionsController < ApplicationController
  before_action :require_login
  before_action :authorize_subscription, only: [:index, :create]
  before_action :set_subscription, only: [:destroy, :update, :skip, :deliver]
  after_action :verify_authorized

  def index
    @subscriptions = current_user.subscriptions
  end

  def create
    course_id = params[:course_id]
    @subscription = Subscription.create(user_id: current_user.id, course_id: course_id, delivery_hours: ['8:00'])
    @subscription.set_deliveries
    redirect_to course_path(course_id)
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

    redirect_to @subscription.course
  end


  # 現在の本をスキップ
  def skip
    @subscription.skip_current_book
    redirect_to @subscription.course
  end


  #FIXME: テスト配信メソッド
  def deliver
    @delivery = @subscription.deliveries.includes(:user, :book).where(delivered: false).order(:deliver_at).first
    @delivery.try(:deliver)
    flash[:success] = 'メールを配信しました！'
    redirect_to @subscription.course
  end


  private
    def set_subscription
      @subscription = Subscription.find(params[:id])
      authorize @subscription
    end

    def authorize_subscription
      authorize Subscription
    end
end
