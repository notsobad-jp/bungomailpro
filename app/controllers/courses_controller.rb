class CoursesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :authorize_course, only: [:index, :new, :create, :owned]
  before_action :set_course_with_books, only: [:show, :edit, :update, :publish, :destroy]
  after_action :verify_authorized


  def index
    @courses = Course.where(status: 2)
  end

  def show
    @subscription = current_user.subscriptions.find_by(course_id: @course.id) if current_user
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
      flash[:success] = 'コースを作成しました🎉'
      redirect_to owned_courses_path
    else
      render :new
    end
  end

  def update
    if @course.update(course_params)
      flash[:success] = 'コースを保存しました🎉'
      redirect_to owned_courses_path
    else
      render :edit
    end
  end

  def publish
    @course.update(status: 2)
    flash[:success] = 'コースを公開しました🎉'
    redirect_to owned_courses_path
  end

  def destroy
    @course.update(status: 3)
    flash[:success] = 'コースを削除しました'
    redirect_to owned_courses_path
  end

  def owned
    @courses = policy_scope current_user.own_courses
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
