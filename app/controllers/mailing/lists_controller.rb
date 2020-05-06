class Mailing::ListsController < Mailing::ApplicationController
  skip_before_action :require_login, only: [:books]

  def books
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @campaign_groups = CampaignGroup.where(list_id: params[:id], start_at: start..start.end_of_year).order(:start_at)
  end
end
