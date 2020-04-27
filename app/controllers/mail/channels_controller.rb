class Mail::ChannelsController < Mail::ApplicationController
  before_action :set_active_tab
  before_action :set_channel, except: [:index, :new, :create]

  def index
    @channels = current_user.subscribed_channels
  end

  def new
    @channel = authorize Channel.new
  end

  def create
    @channel = authorize current_user.channels.new(channel_params)

    if @channel.save
      flash[:success] = 'Channel created!'
      redirect_to channel_path(@channel)
    else
      flash[:error] = 'Sorry somethin went wrong. Please check the data and try again.'
      render :new
    end
  end

  def show
    @book_assignment = @channel.current_book_assignment
    if params[:status] == "finished"
      @book_assignments = @channel.book_assignments.where(status: [:finished, :skipped])
    else
      @book_assignments = @channel.book_assignments.stocked
    end
    @condition = @channel.search_condition
  end

  def edit
  end

  def update
    if @channel.update(channel_params)
      flash[:success] = 'Channel updated!'
      redirect_path = params[:redirect_to] || channel_path(@channel)
      redirect_to redirect_path
    else
      flash[:error] = 'Sorry somethin went wrong. Please check the data and try again.'
      render :edit
    end
  end

  def destroy
    @channel.destroy
    flash[:success] = 'Deleted the channel successfully!'
    redirect_to channels_path
  end

  private

  def channel_params
    params.require(:channel).permit(:title, :description, :public, :delivery_time, :words_per_day, :chars_per_day, :search_condition_id)
  end

  def set_active_tab
    @active_tab = :channels
  end

  def set_channel
    @channel = authorize Channel.find(params[:id])
  end
end
