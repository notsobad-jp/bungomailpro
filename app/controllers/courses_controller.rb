class CoursesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :authorize_course, only: [:index, :new, :create]
  before_action :set_course_with_books, only: [:show, :edit, :update, :publish, :destroy]
  after_action :verify_authorized


  def index
    @courses = Course.where(status: 2)
  end

  def show
    @user_course = current_user.user_courses.find_by(course_id: @course.id) if current_user
  end

  def new
    @course = Course.new
  end

  def edit
  end

  def create
    @course = Course.new course_params
    @course.owner_id = current_user.id

    if @course.save
      redirect_to course_path @course
    else
      render :new
    end
  end

  def update
    if @course.update(course_params)
      redirect_to course_path @course
    else
      render :edit
    end
  end

  def publish
    @course.update(status: 2)
    redirect_to course_path @course
  end

  def destroy
    @course.update(status: 3)
    redirect_to courses_path
  end


  private
    def course_params
      params.require(:course).permit(:title, :description, course_books_attributes: [:id, :index, :book_id, :_destroy])
    end

    def set_course_with_books
      @course = Course.includes(course_books: :book).find(params[:id])
      authorize @course
    end

    def authorize_course
      authorize Course
    end
end
