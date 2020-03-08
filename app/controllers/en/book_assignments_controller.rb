class En::BookAssignmentsController < En::ApplicationController
  # 現在のBookAssignmentを削除して新しい本をセット
  def skip
    @book_assignment = BookAssignment.find(params[:id])
    @book_assignment.feeds.where(scheduled_at: nil).destroy_all
    @book_assignment.skipped!
    current_user.delay.assign_book_and_set_feeds

    flash[:success] = 'Skipped successfully! The new book will be sent from tomorrow.'
    redirect_to mypage_path
  end
end
