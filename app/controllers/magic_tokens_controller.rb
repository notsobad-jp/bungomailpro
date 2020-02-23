class MagicTokensController < ApplicationController
  def new
    redirect_to subscriptions_path if current_user
    @breadcrumbs << { name: 'Signin' }
  end

  def create
    @user = User.find_or_create_by(email: params[:email])
    if @user.try(:persisted?) && @user.try(:email) != 'bungomail-text@notsobad.jp'
      @user.deliver_magic_login_instructions!
      flash[:success] = 'We sent you an email with signin URL.'
      redirect_to en_root_path
    else
      flash[:error] = 'メールアドレスが正しくないようです…😢もう一度ご確認ください。'
      redirect_to login_path
    end
  end

  def auth
    @token = params[:token]
    @user = User.load_from_magic_login_token(params[:token])

    if @user.blank?
      not_authenticated
      flash[:error] = 'Sorry failed to signin…'
      redirect_to en_root_path
    else
      auto_login(@user)
      remember_me!
      flash[:success] = 'Signin successful!'
      redirect_to en_root_path
    end
  end

  def destroy
    logout
    flash[:info] = 'Signed out successfully.'
    redirect_to en_root_path
  end
end
