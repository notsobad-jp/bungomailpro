class SubscriptionsController < ApplicationController
  def create
    @channel = Channel.find(params[:channel_id])
    begin
      google_action = 'insert' if @channel.google_group_key.present?
      current_user.subscription_logs.create!(channel_id: @channel.id, status: 'active', google_action: google_action)
      flash[:success] = '登録完了しました！翌日の配信からメールが届きます。<a href="https://blog.bungomail.com/entry/2018/05/21/172542" target="_blank" class="text-link">メールの受信設定</a>を事前に必ずご確認ください。'
    rescue => e
      logger.error "[Error]Subscription failed: #{e.message}, #{current_user.id}"
      flash[:error] = '【エラー】処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path(@channel)
  end

  def destroy
    @sub = Subscription.find(params[:id])
    begin
      google_action = 'delete' if @sub.channel.google_group_key.present?
      current_user.subscription_logs.create!(channel_id: @sub.channel_id, status: 'canceled', google_action: google_action)
      flash[:success] = '購読解除しました！次回配信からメールが届かなくなります。'
    rescue => e
      logger.error "[Error]Unsubscription failed: #{e.message}, #{current_user.id}"
      flash[:error] = '【エラー】処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path(@sub.channel)
  end
end
