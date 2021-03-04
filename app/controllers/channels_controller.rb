class ChannelsController < ApplicationController
  skip_before_action :require_login, only: [:index, :show, :feed]
  after_action :authorize_record

  def index
    @channels = Channel.where.not(code: nil)
    @meta_title = '公開チャネル'
  end

  def show
    codes = Channel.pluck(:code).compact # 公開チャネルはcodeでチャネル検索
    @channel = codes.include?(params[:id]) ? Channel.find_by(code: params[:id]) : Channel.find(params[:id])
    @book_assignments = @channel.book_assignments.includes(:book).where("start_date < ?", Date.current).order(start_date: :desc).page(params[:page]).per 10
    @subscription = Subscription.find_by(user_id: current_user.id, channel_id: @channel.id) if current_user

    @meta_title = @channel.title || 'マイチャネル'
  end

  def feed
    codes = Channel.pluck(:code).compact # 公開チャネルはcodeでチャネル検索
    @channel = codes.include?(params[:id]) ? Channel.find_by(code: params[:id]) : Channel.find(params[:id])
    @feeds = @channel.feeds.delivered.order('feeds.delivery_date DESC').limit(30)
  end

  private

  def authorize_record
    authorize @channel || Channel
  end
end
