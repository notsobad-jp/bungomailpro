class MagicTokensController < ApplicationController
  def new
    redirect_to subscriptions_path if current_user
  end

  def create
    @user = User.find_or_create_by(email: params[:email])
    @user.deliver_magic_login_instructions!
    flash[:success] = 'ログインURLをメールで送信しました！（届くまで数分程度かかる場合があります）'
    redirect_to root_path
  end

  def auth
    @token = params[:token]
    @user = User.load_from_magic_login_token(params[:token])

    if @user.blank?
      not_authenticated
      flash[:error] = 'ログインに失敗しました…😢'
      return
    else
      auto_login(@user)
      remember_me!
      @user.clear_magic_login_token!
      flash[:success] = 'ログインしました！'
      redirect_to(root_path, notice: 'Logged in successfully')
    end
  end

  def destroy
    logout
    flash[:info] = 'ログアウトしました！'
    redirect_to root_path
  end
end
