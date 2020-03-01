class En::UsersController < En::ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    if @user.persisted?
      UserMailer.magic_login_email(@user).deliver
      flash[:info] = 'This email address is already registered. We sent you a sign-in email.'
      return redirect_to root_path
    end

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
    @assigned_book = AssignedBook.includes(:guten_book, :feeds).where(user_id: current_user.id, status: 'active').first
    @breadcrumbs << { name: 'Mypage' }
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
