class SubscriptionsController < ApplicationController
  def create
    @channel = Channel.find(params[:channel_id])
    begin
      @channel.add_subscriber(current_user)
      flash[:success] = '登録完了しました！明日の配信からメールが届きます。<a href="https://blog.bungomail.com/entry/2018/05/21/172542" target="_blank" class="text-link">メールの受信設定</a>を事前に必ずご確認ください。'
    rescue => e
      logger.error "[Subscription Error]#{e.message}, #{current_user.id}"
      flash[:error] = '【エラー】処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path(@channel)
  end

  def destroy
    @sub = Subscription.find(params[:id])
    begin
      @sub.channel.delete_subscriber(current_user)
      flash[:success] = '購読解除しました！次回配信からメールが届かなくなります。'
    rescue => e
      logger.error "[Unsubscription Error]#{e.message}, #{current_user.id}"
      flash[:error] = '【エラー】処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
    end
    redirect_to channel_path(@sub.channel)
  end
end
