class Mail::MagicTokensController < Mail::ApplicationController
  skip_before_action :require_login, except: [:destroy]

  def new
    redirect_to mypage_path if current_user
    @breadcrumbs << { name: 'Signin' }
  end

  def create
    @user = User.find_by(email: params[:email])
    return redirect_to login_path, flash: { error: 'This email address is not registered. Please register first or try another address.' } unless @user

    UserMailer.magic_login_email(@user).deliver
    flash[:success] = 'We sent you an email with signin URL.'
    redirect_to root_path
  end

  def auth
    @token = params[:token]
    @user = User.load_from_magic_login_token(params[:token])
    return not_authenticated if @user.blank?

    auto_login(@user)
    remember_me!
    flash[:success] = 'Signin successful!'
    redirect_to mypage_path
  end

  def destroy
    logout
    flash[:info] = 'Signed out successfully.'
    redirect_to root_path
  end
end
