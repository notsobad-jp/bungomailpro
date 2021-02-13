class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :activate]

  def new
    @meta_title = "アカウント登録"
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    if @user.persisted?
      BungoMailer.magic_login_email(@user).deliver
      flash[:info] = '登録済みのアドレスに認証用メールを送信しました。メール内のリンクからサイトにアクセスしてください。'
      return redirect_to root_path
    end

    # sorceryのuser_activationで、create後は自動的にactivationメールが送られる
    if @user.save
      flash[:success] = '登録いただいたアドレスに認証用メールを送信しました。メール内のリンクからアクセスして、アカウントを認証してください。'
    else
      flash[:error] = '処理に失敗しました。。再度試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to login_path
  end

  def show
    @user = authorize User.find(params[:id])
    @campaign_group = CampaignGroup.where("start_at < ?", Time.current).order(start_at: :desc).first
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
      recipient = @user.create_recipient rescue nil
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

  def start_trial_now
    @user = authorize User.find(params[:id])
    @user.start_trial_now
    redirect_to(user_path(@user), flash: { success: 'トライアルを開始しました！次回配信分からメールが届くようになります。' })
  rescue => error
    redirect_to(user_path(@user), flash: { error: '処理に失敗しました。。再度試してもうまく行かない場合、お手数ですが運営までお問い合わせください。' })
  end

  def pause_subscription
    @user = authorize User.find(params[:id])
    @user.pause_subscription
    @user.charge.refund_latest_payment if Time.current.day <= 7 # 7日以前なら返金処理
    redirect_to(user_path(@user), flash: { success: '配信を一時停止しました。翌月から自動的に配信が再開します。' })
  rescue => error
    redirect_to(user_path(@user), flash: { error: '処理に失敗しました。。再度試してもうまく行かない場合、お手数ですが運営までお問い合わせください。' })
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
