class MagicTokensController < ApplicationController
  skip_before_action :require_login, except: [:destroy]

  def new
    @meta_title = 'ログイン'
    redirect_to user_path(current_user) if current_user
  end

  def create
    @user = User.find_by(email: params[:email])
    return redirect_to login_path, flash: { error: 'メールアドレスが見つかりませんでした。。初めての方はアカウント登録してください。' } unless @user

    @user.generate_magic_login_token!
    BungoMailer.with(user: @user).magic_login_email.deliver_later
    flash[:success] = 'ログイン用URLを送信しました！メールに記載されたURLからログインしてください。'
    redirect_to login_path
  end

  def auth
    @token = params[:token]
    @user = User.load_from_magic_login_token(params[:token])
    return not_authenticated if @user.blank?

    auto_login(@user)
    remember_me!
    flash[:success] = 'Signin successful!'
    redirect_to user_path(@user)
  end

  def destroy
    logout
    flash[:info] = 'Signed out successfully.'
    redirect_to root_path
  end
end
