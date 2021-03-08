class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :activate]

  def new
    redirect_to mypage_path if current_user
    @meta_title = "アカウント登録"
    @user = User.new
  end

  def create
    if User.find_by(email: user_params[:email])
      flash[:warning] = 'このアドレスはすでに登録されているようです。こちらのページからログインしてください。'
      return redirect_to login_path
    end

    begin
      user = User.create!(email: user_params[:email])
      BungoMailer.with(user: user).activation_email.deliver_later(queue: 'activation')
      flash[:success] = '登録いただいたアドレスに認証用メールを送信しました。メール内のリンクをクリックして、アカウントを認証してください。'
    rescue => e
      # リニューアル以降に退会したユーザーの再登録など
      logger.error "[Error] User registration failed: #{e}"
      flash[:error] = '処理に失敗しました。。再度試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to signup_path
  end

  def mypage
    @meta_title = 'マイページ'
    @user = current_user
    @subscriptions = @user.subscriptions.includes(channel: :channel_profile)
  end

  def activate
    @user = User.load_from_activation_token(params[:id])
    return not_authenticated unless @user

    @user.activate!
    auto_login(@user)

    redirect_to(mypage_path, flash: { success: 'アカウント登録が完了しました🎉 翌日からメール配信が始まります。' })
  end

  # TODO: 有料プランの場合はStripeの購読も削除する
  def destroy
    if current_user.destroy
      logout
      flash[:info] = '退会処理が完了しました。翌日の配信からメールが届かなくなります。これまでのご利用ありがとうございました。'
    else
      flash[:error] = '処理に失敗しました。。再度試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to(root_path)
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
