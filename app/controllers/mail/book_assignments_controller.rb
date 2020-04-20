class Mail::BookAssignmentsController < Mail::ApplicationController
  before_action :set_channel_and_book, only: [:new, :create]

  def new
    @book_assignment = @channel.book_assignments.new
    @book_assignment.book = @book

    @categories = @book.class::CATEGORIES
    @category = @categories[@book.category_id.to_sym]
    @author = { id: @book.author_id, name: @book.author_name }

    @breadcrumbs << { name: 'Add to stock' }
  end

  def create
    @book_assignment = @channel.book_assignments.new
    @book_assignment.book = @book

    if @book_assignment.save
      flash[:success] = 'Added the stocked book successfully!'
    else
      flash[:error] = 'Sorry somethin went wrong. Please check the data and try again.'
    end
    redirect_to mypage_path
  end

  # 現在のBookAssignmentを削除して新しい本をセット
  def skip
    @book_assignment = BookAssignment.find(params[:id])
    @book_assignment.feeds.where(scheduled_at: nil).destroy_all
    @book_assignment.skipped!
    @book_assignment.channel.delay.assign_book_and_set_feeds

    flash[:success] = 'Skipped successfully! The new book will be sent from tomorrow.'
    redirect_to mypage_path
  end

  def destroy
    @book_assignment = BookAssignment.find(params[:id])
    @book_assignment.destroy
    flash[:success] = 'Deleted the stocked book successfully!'
    redirect_to mypage_path
  end

  private

  def set_channel_and_book
    @channel = Channel.find(params[:channel_id])
    book_class = params[:book_type].constantize if %w(AozoraBook GutenBook).include?(params[:book_type])
    @book = book_class&.find_by(id: params[:book_id])
    raise ActiveRecord::RecordNotFound unless @channel && @book&.category && @book&.author_id
  end
end
