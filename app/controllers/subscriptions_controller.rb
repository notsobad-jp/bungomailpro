class SubscriptionsController < ApplicationController
  before_action :require_login

  def index
    @user_courses = current_user.user_courses
  end

  def create
    @course = Course.find(params[:course_id])
    current_user.user_courses.create(course_id: @course.id, delivery_hours: ['7:00', '23:00'])
    redirect_to @course
  end

  def destroy
    @course = Course.find(params[:course_id])
    current_user.user_courses.find_by(course_id: @course.id).destroy
    redirect_to @course
  end

  #TODO: 一時的にテストに使用
  def edit
    @course = Course.find(params[:course_id])
    user_course = current_user.user_courses.find_by(course_id: @course.id)

    if params[:skip]
      user_course.skip_current_book
    else
      user_course.deliveries.find_by(delivered: false).update(delivered: true)
      user_course.set_next_delivery
    end
    redirect_to @course
  end

  def update
    @course = Course.find(params[:course_id])
    user_course = current_user.user_courses.find_by(course_id: @course.id)
    user_course.update(status: params[:status])
  end
end
