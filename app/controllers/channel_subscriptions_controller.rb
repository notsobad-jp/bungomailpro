class ChannelSubscriptionsController < ApplicationController
  skip_before_action :require_login

  @@official_channel_id = Channel.find_by(code: 'bungomail-official').id

  # 購読
  def create
    begin
      user = User.find_or_create_by(email: params[:email])
      if user.subscriptions.present?
        flash[:error] = 'このメールアドレスはすでに登録されています'
      else
        user.subscription_logs.create(channel_id: @@official_channel_id, apply_at: Time.current, status: 'active', google_action: 'insert')
        flash[:success] = '登録完了しました！翌日の配信からメールが届きます。<a href="https://blog.bungomail.com/entry/2018/05/21/172542" target="_blank" class="text-link">メールの受信設定</a>を事前に必ずご確認ください。'
      end
    rescue => e
      logger.error "[Subscription Error]#{e.message}, #{params[:email]}"
      flash[:error] = 'メールアドレスの登録に失敗しました。。再度試してもうまくいかない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
    end
    redirect_to root_path
  end

  # 配信停止
  def destroy
    begin
      user = User.find_by(email: params[:email])
      if !user || user.subscriptions.blank?
        flash[:error] = 'メールアドレスが見つかりませんでした。。再度試してもうまくいかないない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
        return redirect_to page_path(:unsubscribe)
      end

      # 登録解除
      if params[:action_type] == 'unsubscribed'
        user.subscription_logs.create(channel_id: @@official_channel_id, apply_at: Time.current, status: 'canceled', google_action: 'delete')
        flash[:success] = '購読を解除しました。明日の配信からメールが届かなくなります。これまでのご利用ありがとうございました。'
      # 月末まで一時停止
      elsif params[:action_type] == 'paused'
        user.subscription_logs.create(channel_id: @@official_channel_id, apply_at: Time.current, status: 'paused', google_action: 'update')
        user.subscription_logs.create(channel_id: @@official_channel_id, apply_at: Time.current.next_month.beginning_of_month, status: 'active', google_action: 'update')
        flash[:success] = '月末まで配信を一時停止しました。来月になると自動で配信が再開されます。'
      end

      redirect_to root_path
    rescue => e
      logger.error "[Unsubscription Error]#{e.message}, #{params[:email]}"
      flash[:error] = '処理に失敗しました。。再度試してもうまくいかないない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
      redirect_to page_path(:unsubscribe)
    end
  end
end
