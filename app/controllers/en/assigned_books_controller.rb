class En::AssignedBooksController < En::ApplicationController
  # AssignedBookを削除して新しい本をセット
  def skip
    @assigned_book = AssignedBook.find(params[:id])
    @assigned_book.feeds.where(scheduled_at: nil).destroy_all
    @assigned_book.update(status: 'skipped')
    current_user.delay.assign_book_and_set_feeds

    flash[:success] = 'Skipped successfully! The new book will be sent from tomorrow.'
    redirect_to mypage_path
  end
end
