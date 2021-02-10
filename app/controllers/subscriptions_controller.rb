class SubscriptionsController < ApplicationController
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
                        'メールアドレスの登録に失敗しました。。再度送信しても登録できない場合、お手数ですがinfo@notsobad.jpまでお問い合わせください。'
                      else
                        e.message
                      end
    end
    redirect_to root_path
  end
end
