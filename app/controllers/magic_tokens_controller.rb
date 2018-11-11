class MagicTokensController < ApplicationController
  def new
  end

  def create
    @user = User.find_or_create_by(email: params[:email])
    @user.deliver_magic_login_instructions!
    redirect_to(root_path, notice: 'Instructions have been sent to your email.')
  end

  def auth
    @token = params[:token]
    @user = User.load_from_magic_login_token(params[:token])

    if @user.blank?
      not_authenticated
      return
    else
      auto_login(@user)
      remember_me!
      @user.clear_magic_login_token!
      redirect_to(root_path, notice: 'Logged in successfully')
    end
  end

  def destroy
    logout
    redirect_to(root_path, notice: 'Logged out!')
  end
end
