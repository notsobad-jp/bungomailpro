class Mailing::ListsController < Mailing::ApplicationController
  skip_before_action :require_login, only: [:books]

  def books
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @campaign_groups = CampaignGroup.includes(:book).where(list_id: params[:id], start_at: start..start.end_of_year).where("start_at < ?", Time.current).order(:start_at)

    @meta_title = "ブンゴウメールの過去配信作品一覧 - #{year}年"
    @meta_description = 'これまでにブンゴウメールで配信した作品の一覧です。'
  end
end
