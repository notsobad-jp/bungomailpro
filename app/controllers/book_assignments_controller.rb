class BookAssignmentsController < ApplicationController
  def create
    @channel = Channel.find(book_assignment_params[:channel_id])
    @book_assignment = @channel.book_assignments.new(
      book_id: book_assignment_params[:book_id],
      book_type: book_assignment_params[:book_type],
      start_date: book_assignment_params[:start_date],
      end_date: book_assignment_params[:end_date],
    )
    authorize @book_assignment

    if @book_assignment.save
      @book_assignment.delay.create_and_schedule_feeds
      flash[:success] = '配信予約が完了しました！'
    else
      flash[:error] = @book_assignment.errors.values.join("。") || '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to aozora_book_path(book_assignment_params[:book_id])
  end

  private

  def book_assignment_params
    params.require(:book_assignment).permit(:book_id, :book_type, :channel_id, :start_date, :end_date)
  end
end
