class En::UsersController < En::ApplicationController
  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    return redirect_to root_path, flash: { error: 'This email address is already registered.' } if @user.persisted?

    if @user.save
      # 本を選んでfeedsをセット。最初のfeedはすぐに配信する
      @user.delay.assign_book_and_set_feeds(deliver_now: true)
      flash[:success] = 'Account registered! Please check the first email we send you in a minute :)'
    else
      flash[:error] = 'Sorry something seems to be wrong with your email address. Please check and try again.'
    end
    redirect_to root_path
  end

  def mypage
    @breadcrumbs << { name: 'Mypage' }
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
