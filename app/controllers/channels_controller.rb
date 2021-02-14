class ChannelsController < ApplicationController
  skip_before_action :require_login, only: [:show]

  def show
    @channel = Channel.find(params[:id])
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @book_assignments = @channel.book_assignments.includes(:book).where(start_at: start..start.end_of_year).where("start_at < ?", Time.current).order(:start_at)
    @meta_title = @channel.title
  end
end
