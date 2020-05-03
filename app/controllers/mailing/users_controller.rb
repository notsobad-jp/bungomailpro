class Mailing::UsersController < Mailing::ApplicationController
  skip_before_action :require_login, only: [:new, :create, :activate]

  def new
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    if @user.persisted?
      UserMailer.magic_login_email(@user).deliver
      flash[:info] = 'This email address is already registered. We sent you a sign-in email.'
      return redirect_to root_path
    end

    if @user.save
      flash[:success] = "Account registered! You'll start receiving the email from tomorrow :)"
    else
      flash[:error] = 'Sorry something seems to be wrong with your email address. Please check and try again.'
    end
    redirect_to login_path
  end

  def show
    @user = authorize User.find(params[:id])
  end

  def edit
    @user = authorize User.find(params[:id])
  end

  def update
    @user = authorize User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Your data is saved successfully!'
      redirect_to user_path(@user)
    else
      flash[:error] = 'Sorry we failed to save your data. Please check the input again.'
      render :edit
    end
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!

      # SendGridにrecipient追加（翌月初までListには追加しない）
      recipient = Sendgrid.call(path: "contactdb/recipients", params: [{ email: @user.email }]) rescue nil
      @user.update(
        sendgrid_id: recipient&.dig("persisted_recipients", 0),
        trial_end_at: Time.current.next_month.end_of_month, # 翌月末まで無料期間
      )

      auto_login(@user)
      redirect_to(user_path(@user), flash: { success: 'アカウント登録が完了しました🎉' })
    else
      not_authenticated
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
