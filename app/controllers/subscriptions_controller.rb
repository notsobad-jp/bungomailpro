class SubscriptionsController < ApplicationController
  skip_before_action :require_login

  # 購読
  def create
    service = GoogleDirectoryService.instance

    begin
      member = Google::Apis::AdminDirectoryV1::Member.new(email: params[:email])
      service.insert_member(ENV['GOOGLE_GROUP_KEY'], member)
      flash[:success] = '登録完了しました！明日の配信からメールが届きます。<a href="https://blog.bungomail.com/entry/2018/05/21/172542" target="_blank" class="text-link">メールの受信設定</a>を事前に必ずご確認ください。'
      SubscriptionLog.create!(email: params[:email], action: "subscribed")
    rescue => e
      flash[:error] = case e.status_code
                      when 409
                        'このメールアドレスはすでに登録されています'
                      when 404
                        'メールアドレスの登録に失敗しました。。再度試してもうまくいかない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
                      else
                        e.message
                      end
    end
    redirect_to root_path
  end

  # 配信停止
  def destroy
    service = GoogleDirectoryService.instance

    begin
      # 登録解除
      if params[:action_type] == 'unsubscribed'
        service.delete_member(ENV['GOOGLE_GROUP_KEY'], params[:email])
        flash[:success] = '購読を解除しました。明日の配信からメールが届かなくなります。これまでのご利用ありがとうございました。'
      # 月末まで一時停止
      elsif params[:action_type] == 'paused'
        member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: 'NONE')
        service.patch_member(ENV['GOOGLE_GROUP_KEY'], params[:email], member)
        flash[:success] = '月末まで配信を一時停止しました。来月になると自動で配信が再開されます。'
      end

      SubscriptionLog.create!(email: params[:email], action: params[:action_type])
      redirect_to root_path
    rescue => e
      flash[:error] = case e.status_code
                      when 404
                        'メールアドレスが見つかりませんでした。。再度試してもうまくいかないない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
                      else
                        e.message
                      end
      redirect_to page_path(:unsubscribe)
    end
  end
end
