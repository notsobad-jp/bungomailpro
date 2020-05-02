class Mailing::SearchConditionsController < Mailing::ApplicationController
  def index
    @search_conditions = policy_scope(SearchCondition)
    @channels = policy_scope(Channel)
    @active_tab = :books
  end

  def create
    condition = authorize current_user.search_conditions.new(
      query: params[:query],
      book_type: params[:book_type],
    )

    if condition.save
      flash[:success] = 'Saved the condition!'
    else
      flash[:error] = 'Sorry something went wrong. Please check the data and try again.'
    end
    redirect_to search_conditions_path
  end

  def destroy
    condition = authorize SearchCondition.find(params[:id])
    condition.destroy
    flash[:success] = 'Deleted the condition!'
    redirect_to search_conditions_path
  end
end
