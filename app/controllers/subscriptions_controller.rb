class SubscriptionsController < ApplicationController
  after_action :authorize_record

  # 購読
  def create
    @channel = Channel.find(params[:channel_id])
    begin
      current_user.subscriptions.create!(channel_id: @channel.id)
      flash[:success] = '登録完了しました！翌日の配信からメールが届きます。<a href="https://blog.bungomail.com/entry/2018/05/21/172542" target="_blank" class="text-link">メールの受信設定</a>を事前に必ずご確認ください。'
    rescue => e
      logger.error "[Error]Subscription failed: #{e.message}, #{current_user.id}"
      flash[:error] = '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path(@channel)
  end

  # 一時停止/再開
  def update
    @sub = Subscription.find(params[:id])
    paused = params[:paused] == 'true'
    begin
      @sub.update!(paused: paused)
      message = paused ? '配信を月末まで一時停止しました。翌月初から自動的に配信を再開します。' : '配信を再開しました！翌日の配信からメールが届くようになります。'
      flash[:success] = message
    rescue => e
      logger.error "[Error]Pausing failed: #{e.message}, #{current_user.id}"
      flash[:error] = '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path(@sub.channel)
  end

  # 解約
  def destroy
    @sub = Subscription.find(params[:id])
    begin
      @sub.destroy
      flash[:success] = '購読解除しました！次回配信からメールが届かなくなります。'
    rescue => e
      logger.error "[Error]Unsubscription failed: #{e.message}, #{current_user.id}"
      flash[:error] = '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path(@sub.channel)
  end

  private

  def authorize_record
    authorize @sub || Subscription
  end
end
