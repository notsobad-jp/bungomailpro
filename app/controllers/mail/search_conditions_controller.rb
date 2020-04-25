class Mail::SearchConditionsController < Mail::ApplicationController
  def index
    @search_conditions = current_user.search_conditions.order(created_at: :desc)
  end

  # def new
  #   @search_condition = current_user.search_conditions.new(
  #     query: params[:query],
  #     book_type: params[:book_type],
  #     books_count: params[:books_count],
  #   )
  #   @channel_select_options = current_user.channels.pluck(:title, :id)
  # end

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
