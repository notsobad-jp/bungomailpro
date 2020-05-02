class Mailing::BookAssignmentsController < Mailing::ApplicationController
  before_action :set_book, only: [:create]

  def index
    @channel = authorize Channel.find(params[:channel_id])
    @book_assignments = @channel.book_assignments.stocked
  end

  def create
    @channel = Channel.find(params[:channel_id])
    @book_assignment = @channel.book_assignments.new(book_id: @book.id, book_type: @book.class.name)

    if @book_assignment.save
      flash[:success] = 'Added the stocked book successfully!'
    else
      flash[:error] = 'Sorry somethin went wrong. Please check the data and try again.'
    end
    redirect_to channel_path(@channel)
  end

  # 現在のBookAssignmentを削除して新しい本をセット
  def skip
    @book_assignment = BookAssignment.find(params[:id])
    @book_assignment.feeds.where(scheduled_at: nil).destroy_all
    @book_assignment.skipped!
    @book_assignment.channel.delay.assign_book_and_set_feeds

    flash[:success] = 'Skipped successfully! The new book will be sent from tomorrow.'
    redirect_to channel_path(@book_assignment.channel)
  end

  def destroy
    @book_assignment = BookAssignment.find(params[:id])
    @book_assignment.destroy
    @book_assignment.channel.update(active: false) if @book_assignment.active?
    flash[:success] = 'Deleted the stocked book successfully!'
    redirect_to channel_path(@book_assignment.channel)
  end

  private

  def set_book
    book_class = params[:book_type].constantize if %w(AozoraBook GutenBook).include?(params[:book_type])
    @book = book_class&.find_by(id: params[:book_id])
    raise ActiveRecord::RecordNotFound unless @book&.category && @book&.author_id
  end
end
