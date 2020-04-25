class Mail::SearchConditionsController < Mail::ApplicationController
  def index
    @search_conditions = current_user.search_conditions
    @channels = current_user.channels
    @active_tab = :books
  end

  def create
    condition = current_user.search_conditions.new(
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
    condition = SearchCondition.find(params[:id])
    condition.destroy
    flash[:success] = 'Deleted the condition!'
    redirect_to search_conditions_path
  end
end
