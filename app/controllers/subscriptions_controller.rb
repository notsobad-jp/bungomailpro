class SubscriptionsController < ApplicationController
  before_action :require_login
  before_action :authorize_subscription, only: [:index, :create]
  before_action :set_user_course, only: [:destroy, :update, :skip, :deliver]
  after_action :verify_authorized

  def index
    @user_courses = current_user.user_courses
  end

  def create
    course_id = params[:course_id]
    @user_course = UserCourse.create(user_id: current_user.id, course_id: course_id, delivery_hours: ['7:00', '23:00'])
    @user_course.set_deliveries #TODO: delayed_jobつかう
    redirect_to course_path(course_id)
  end

  def destroy
    course = @user_course.course
    @user_course.destroy
    redirect_to course
  end

  # 配信ステータスの変更（一時停止・再開）
  def update
    status = params[:status].to_i
    @user_course.update(status: status)

    # deliveriesの配信状況をアップデート
    if status == 1
      @user_course.restart
    elsif status == 2
      @user_course.pause
    end

    redirect_to @user_course.course
  end


  # 現在の本をスキップ
  def skip
    @user_course.skip_current_book
    redirect_to @user_course.course
  end


  #FIXME: テスト配信メソッド
  def deliver
    @delivery = @user_course.deliveries.includes(:user, :book).where(delivered: false).order(:deliver_at).first
    @delivery.try(:deliver)
    flash[:success] = 'メールを配信しました！'
    redirect_to @user_course.course
  end


  private
    def set_user_course
      @user_course = UserCourse.find(params[:id])
      authorize @user_course
    end

    def authorize_subscription
      authorize UserCourse
    end
end
