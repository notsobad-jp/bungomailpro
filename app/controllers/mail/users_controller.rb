class Mail::UsersController < Mail::ApplicationController
  before_action :set_active_tab
  skip_before_action :require_login, only: [:create]

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    if @user.persisted?
      UserMailer.magic_login_email(@user.id).deliver
      flash[:info] = 'This email address is already registered. We sent you a sign-in email.'
      return redirect_to root_path
    end

    @user.locale = I18n.locale
    @user.timezone = 'Tokyo' if I18n.locale == :ja  # 日本のときはJST。デフォルトはUTC

    if @user.save
      # 本を選んでfeedsをセット。最初のfeedはすぐに配信する
      @user.default_channel.delay.assign_book_and_set_feeds(deliver_now: true)
      flash[:success] = "Account registered! You'll start receiving the email from today :)"
    else
      flash[:error] = 'Sorry something seems to be wrong with your email address. Please check and try again.'
    end
    redirect_to root_path
  end

  def show
    @channels = current_user.channels
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Your data is saved successfully!'
      redirect_to user_path(@user)
    else
      flash[:error] = 'Sorry we failed to save your data. Please check the input again.'
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :timezone, channels_attributes: [:id, :delivery_time, :words_per_day])
  end

  def set_active_tab
    @active_tab = :settings
  end
end
