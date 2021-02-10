class SubscriptionsController < ApplicationController
  # 購読
  def create
    service = GoogleDirectoryService.instance
    member = Google::Apis::AdminDirectoryV1::Member.new(email: params[:email])

    begin
      service.insert_member('test@notsobad.jp', member)
      flash[:success] = '登録完了しました！明日の配信からメールが届きます。<a href="https://blog.bungomail.com/entry/2018/05/21/172542" target="_blank" class="text-link">メールの受信設定</a>を事前に必ずご確認ください。'
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

  # 月末まで一時停止
  def update
    month = Time.current.strftime("%Y%m")
    paused_log = PausedLog.find_or_initialize_by(email: params[:email], month: month)
    if paused_log.persisted?
      redirect_to page_path(:unsubscribe), flash: { error: "このアドレスはすでに月末まで配信停止中です。もし配信が止まらない場合はinfo@notsobad.jpまでお問い合わせください。" } and return
    end

    service = GoogleDirectoryService.instance
    member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: 'NONE')

    begin
      service.patch_member('test@notsobad.jp', params[:email], member)
      paused_log.save!
      flash[:success] = '月末まで配信を一時停止しました。来月になると自動で配信が再開されます。'
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

  # 登録解除
  def destroy
    service = GoogleDirectoryService.instance

    begin
      service.delete_member('test@notsobad.jp', params[:email])
      flash[:success] = '購読を解除しました。明日の配信からメールが届かなくなります。これまでのご利用ありがとうございました。'
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
