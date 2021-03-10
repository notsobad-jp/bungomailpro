class ChannelSubscriptionsController < ApplicationController
  skip_before_action :require_login

  # 3月1日以降のフロー
  ## subscriptionのgoogle callbackはOFFになってる前提で、ここでGoogle更新もやってる

  # 購読
  def create
    service = GoogleDirectoryService.instance
    user = User.find_or_create_by(email: params[:email])

    # 新規作成時は、callbackさせないようにmembership作成（リニューアルまでの暫定措置）
    if !user.membership
      Membership.insert({id: user.id, plan: 'free'})
      user.reload
    end

    # すでに購読済みの場合はエラー
    if user.subscriptions.present?
      return redirect_to root_path, flash: { error: 'このメールアドレスはすでに登録されています' }
    elsif user.errors.present?
      return redirect_to root_path, flash: { error: '登録に失敗しました。。Gmailのエイリアスアドレスなどは利用できませんので、他のアドレスをご利用ください。' }
    end

    begin
      member = Google::Apis::AdminDirectoryV1::Member.new(email: params[:email])
      service.insert_member(ENV['GOOGLE_GROUP_KEY'], member)
      user.subscriptions.create(channel_id: Channel::OFFICIAL_CHANNEL_ID)
      flash[:success] = '登録完了しました！翌日の配信からメールが届きます。<a href="https://blog.bungomail.com/entry/2018/05/21/172542" target="_blank" class="text-link">メールの受信設定</a>を事前に必ずご確認ください。'
    rescue => e
      logger.error "[Subscription Error]#{e.message}, #{params[:email]}"
      flash[:error] = 'メールアドレスの登録に失敗しました。。再度試してもうまくいかない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
    end
    redirect_to root_path
  end

  # 配信停止
  def destroy
    service = GoogleDirectoryService.instance
    user = User.find_by(email: params[:email])
    sub = user.subscriptions.find_by(channel_id: Channel::OFFICIAL_CHANNEL_ID) if user
    if !user || !sub
      flash[:error] = 'メールアドレスが見つかりませんでした。。再度試してもうまくいかないない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
      return redirect_to page_path(:unsubscribe)
    end

    # 登録解除
    begin
      if params[:action_type] == 'unsubscribed'
        service.delete_member(ENV['GOOGLE_GROUP_KEY'], params[:email])
        user.destroy!
        flash[:info] = '購読を解除しました。明日の配信からメールが届かなくなります。これまでのご利用ありがとうございました。'
      # 月末まで一時停止
      elsif params[:action_type] == 'paused'
        member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: 'NONE')
        service.patch_member(ENV['GOOGLE_GROUP_KEY'], params[:email], member)
        sub.update!(paused: true)
        flash[:info] = '月末まで配信を一時停止しました。来月になると自動で配信が再開されます。'
      end
      redirect_to root_path
    rescue => e
      logger.error "[Unsubscription Error]#{e.message}, #{params[:email]}"
      flash[:error] = '処理に失敗しました。。再度試してもうまくいかないない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
      redirect_to page_path(:unsubscribe)
    end
  end
end
