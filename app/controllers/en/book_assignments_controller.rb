class En::BookAssignmentsController < En::ApplicationController
  def new
    @book = GutenBook.find(params[:guten_book_id])
    unless @book.category && @book.author_id
      flash[:error] = 'Sorry invalid data. Please search the book again.'
      redirect_to mypage_path
    end
    @book_assignment = BookAssignment.new(guten_book_id: params[:guten_book_id])
    @breadcrumbs << { name: 'Add stock book' }
  end

  def create
    @book = GutenBook.find(params[:guten_book_id])
    current_user.book_assignments.create(guten_book_id: params[:guten_book_id])
    flash[:success] = 'Added the stocked book successfully!'
    redirect_to mypage_path
  end

  # 現在のBookAssignmentを削除して新しい本をセット
  def skip
    @book_assignment = BookAssignment.find(params[:id])
    @book_assignment.feeds.where(scheduled_at: nil).destroy_all
    @book_assignment.skipped!
    current_user.delay.assign_book_and_set_feeds

    flash[:success] = 'Skipped successfully! The new book will be sent from tomorrow.'
    redirect_to mypage_path
  end

  def destroy
    @book_assignment = BookAssignment.find(params[:id])
    @book_assignment.destroy
    flash[:success] = 'Deleted the stocked book successfully!'
    redirect_to mypage_path
  end
end
