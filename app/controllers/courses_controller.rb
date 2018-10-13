class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
    @subscription = current_user.user_courses.find_by(course_id: @course.id) if current_user
  end
end
