class BookAssignmentsController < ApplicationController
  after_action :authorize_record

  # TODO:
  def create
    @channel = Channel.find(params[:channel_id])
    @book_assignment = @channel.book_assignments.new(book_id: params[:book_id], book_type: params[:book_type], count: 30, start_date: Time.zone.tomorrow + 50)
    if @book_assignment.save
      # TODO: workerでchapter分割して配信処理
      flash[:success] = '配信予約が完了しました！'
    else
      p @book_assignment.errors
      flash[:error] = '【エラー】処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to aozora_book_path(params[:book_id])
  end

  private

  def authorize_record
    authorize @book_assignment || BookAssignment
  end
end
