class Mail::ChannelsController < Mail::ApplicationController
  before_action :set_active_tab
  before_action :set_channel, except: [:index, :new, :create]

  def index
    @channels = current_user.subscribed_channels.includes(current_book_assignment: :book)
  end

  def new
    @channel = authorize Channel.new
  end

  def create
    @channel = authorize current_user.channels.new(channel_params)
    @channel.title ||= 'My Channel'

    if @channel.save
      flash[:success] = 'Channel created!'
      redirect_to params[:redirect_to] || channel_path(@channel)
    else
      flash[:error] = 'Sorry something went wrong.. Please check the data and try again.'
      render :new
    end
  end

  def show
    @current_assignment = @channel.current_book_assignment
    @book_assignments = @channel.book_assignments.stocked
    @condition = @channel.search_condition
  end

  def edit
  end

  def update
    if @channel.update(channel_params)
      flash[:success] = 'Channel updated!'
      redirect_to params[:redirect_to] || channel_path(@channel)
    else
      flash[:error] = 'Sorry something went wrong.. Please check the data and try again.'
      render :edit
    end
  end

  def destroy
    @channel.destroy
    flash[:success] = 'Deleted the channel successfully!'
    redirect_to channels_path
  end

  # Auto Select: 本を3冊セレクトしてbook_assignmentsに追加
  def add_books
    @channel.select_book(3).each do |book|
      @channel.book_assignments.new(
        book_type: book.class.name,
        book_id: book.id,
      )
    end

    if @channel.save
      flash[:success] = 'Books added!'
    else
      flash[:error] = 'Sorry something went wrong.. Please try again later.'
    end
    redirect_to channel_path(@channel)
  end

  # 配信開始
  def start
    return redirect_to channel_path(@channel), flash: { error: 'This channel is already started.' } if @channel.active?

    # TODO: activeにしてfeedセットする処理
    @channel.assign_book_and_set_feeds
    @channel.update(active: true)

    flash[:success] = 'Channel started!'
    redirect_to channel_path(@channel)
  end

  private

  def channel_params
    params.fetch(:channel, {}).permit(
      :title, :description, :public, :delivery_time, :words_per_day, :chars_per_day, :search_condition_id, :active,
      search_condition_attributes: [:book_type, query: {}],
      book_assignments_attributes: [:book_id, :book_type],
    )
  end

  def set_active_tab
    @active_tab = :channels
  end

  def set_channel
    @channel = authorize Channel.find(params[:id])
  end
end
