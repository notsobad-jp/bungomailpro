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
      flash[:success] = "Account registered! You'll start receiving the email from today :)"
    else
      flash[:error] = 'Sorry something seems to be wrong with your email address. Please check and try again.'
    end
    redirect_to root_path
  end

  def mypage
    @book_assignment = current_user.current_book_assignment
    @stocked_books = current_user.book_assignments.stocked
    @breadcrumbs << { name: 'Mypage' }
  end

  def edit
    @breadcrumbs << { name: 'Mypage', url: mypage_path }
    @breadcrumbs << { name: 'Delivery Settings' }
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Your data is saved successfully!'
      redirect_to mypage_path
    else
      flash[:error] = 'Sorry we failed to save your data. Please check the input again.'
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :timezone, :delivery_time, :words_per_day)
  end
end
