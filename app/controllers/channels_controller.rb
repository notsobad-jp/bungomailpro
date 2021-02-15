class ChannelsController < ApplicationController
  skip_before_action :require_login, only: [:show]

  def show
    # 公開チャネルはcodeでチャネル検索
    codes = Channel.where.not(code: nil).pluck(:code)
    @channel = codes.include?(params[:id]) ? Channel.find_by(code: params[:id]) : Channel.find(params[:id])

    @book_assignments = @channel.book_assignments.includes(:book).where("start_at < ?", Time.current).order(start_at: :desc).page(params[:page]).per 10
    @meta_title = @channel.title || 'マイチャネル'
  end
end
