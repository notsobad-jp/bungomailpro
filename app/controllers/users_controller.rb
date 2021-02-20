class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :activate]

  def new
    @meta_title = "アカウント登録"
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    if @user.persisted?
      flash[:warning] = 'このアドレスはすでに登録されているようです。こちらのページからログインしてください。'
      return redirect_to login_path
    end

    if @user.save
      BungoMailer.with(user: @user).activation_email.deliver_later
      flash[:success] = '登録いただいたアドレスに認証用メールを送信しました。メール内のリンクをクリックして、アカウントを認証してください。'
    else
      flash[:error] = '処理に失敗しました。。再度試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to signup_path
  end

  def show
    @meta_title = 'マイページ'
    @user = current_user
    @subscriptions = @user.subscriptions.includes(channel: :channel_profile)
    # @user = authorize User.find(params[:id])
    # @campaign_group = CampaignGroup.where("start_at < ?", Time.current).order(start_at: :desc).first
  end
  #
  # def edit
  #   @user = authorize User.find(params[:id])
  # end
  #
  # def update
  #   @user = authorize User.find(params[:id])
  #   if @user.update(user_params)
  #     flash[:success] = 'Your data is saved successfully!'
  #     redirect_to user_path(@user)
  #   else
  #     flash[:error] = 'Sorry we failed to save your data. Please check the input again.'
  #     render :edit
  #   end
  # end

  def activate
    @user = User.load_from_activation_token(params[:id])
    return not_authenticated unless @user

    @user.activate!
    auto_login(@user)

    # 翌月初にBasicプランでトライアル開始→翌月末でキャンセルしてFreeプランになるように予約
    @user.membership.delay(queue: 'schedule_trial').schedule_trial

    redirect_to(mypage_path, flash: { success: 'アカウント登録が完了しました🎉' })
  end

  def destroy
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      current_user.update!(activation_state: nil)
      current_user.membership_logs.create!(plan: 'free', status: "canceled")
      current_user.membership_logs.scheduled.map(&:cancel)
      # TODO: freeチャネルの購読はcronで削除されないので、ここで手動削除しておく
    end
    logout
    redirect_to(root_path, flash: { info: '退会処理が完了しました。翌日の配信からメールが届かなくなります。これまでのご利用ありがとうございました。' })
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
