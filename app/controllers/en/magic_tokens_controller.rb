class En::MagicTokensController < En::ApplicationController
  def auth
    @token = params[:token]
    @user = User.load_from_magic_login_token(params[:token])

    if @user.blank?
      not_authenticated
      flash[:error] = 'Sorry failed to signin…'
      redirect_to root_path
    else
      auto_login(@user)
      remember_me!
      flash[:success] = 'Signin successful!'
      redirect_to root_path
    end
  end

  def destroy
    logout
    flash[:info] = 'Signed out successfully.'
    redirect_to root_path
  end
end
