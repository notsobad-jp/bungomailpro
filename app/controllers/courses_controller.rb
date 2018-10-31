class CoursesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :authorize_course, only: [:index, :new, :create]
  before_action :set_course_with_books, only: [:show, :edit, :update]
  after_action :verify_authorized


  def index
    @courses = Course.all
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
    authorize Course

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
