class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @user = User.find user.id
    @url  = URI.join(root_url, "auth?token=#{@user.magic_login_token}")

    mail(to: @user.email, subject: "【ブンゴウメール】ログイン用URL")
  end


  def deliver_chapter
    @channel = params[:channel]
    @chapter = params[:chapter]

    deliver_at = @channel.deliver_at.first  #FIXME: 複数回配信に未対応
    send_at = Time.current.change(hour: deliver_at)

    xsmtp_api_params = {
      send_at: send_at.to_i,
      to: @channel.subscribers.pluck(:email)
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(
      from: "#{@chapter.book.author} <bungomail@notsobad.jp>",
      to: 'bungomail@notsobad.jp',
      subject: "【ブンゴウメール】#{@chapter.book.title}（#{@chapter.index}/#{@chapter.book.chapters_count}）"
    )
  end


  def test
    @deliver_at = Time.zone.parse(params[:deliver_at])
    @subscription = params[:subscription]
    @chapter = params[:chapter]

    xsmtp_api_params = {
      send_at: @deliver_at.to_i,
      to: [@subscription.user.email, User.find(2).email]
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(
      from: "#{@chapter.book.author} <bungomail@notsobad.jp>",
      subject: @chapter.book.title
    )
  end
end
