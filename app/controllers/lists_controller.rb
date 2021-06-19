class ListsController < ApplicationController
  def books
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @campaign_groups = CampaignGroup.includes(:book).where(list_id: params[:id], start_at: start..start.end_of_year).where("start_at < ?", Time.current).order(:start_at)
    @meta_title = "過去配信作品（#{year}）"
  end
end
