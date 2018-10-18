class SubscriptionsController < ApplicationController
  before_action :require_login
  before_action :set_course_and_user_course, only: [:destroy, :update, :edit, :skip, :deliver]

  def index
    @user_courses = current_user.user_courses
  end

  def create
    @course = Course.find(params[:course_id])
    @user_course = current_user.user_courses.create(course_id: @course.id, delivery_hours: ['7:00', '23:00'])
    @user_course.set_next_delivery
    redirect_to @course
  end

  def destroy
    @user_course.destroy
    redirect_to @course
  end

  def edit
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

    redirect_to @course
  end


  # 現在の本をスキップ
  def skip
    @user_course.skip_current_book
    redirect_to @course
  end


  #FIXME: テスト配信メソッド
  def deliver
    @delivery = @user_course.deliveries.find_by(delivered: false)
    @delivery.deliver
    redirect_to @course
  end


  private
    def set_course_and_user_course
      @user_course = UserCourse.find(params[:user_course_id])
      @course = @user_course.course
    end
end
