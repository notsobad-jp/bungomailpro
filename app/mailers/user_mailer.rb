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
    @subscription = params[:subscription]
    @chapter = params[:delivery]
    mail(
      from: "#{@chapter.book.author} <bungomail@notsobad.jp>",
      to: @subscription.user.email,
      subject: "【ブンゴウメール】#{@chapter.book.title}"
    )
  end


  def test
    @deliver_at = Time.zone.parse(params[:deliver_at])
    @subscription = params[:subscription]
    @chapter = params[:chapter]

    xsmtp_api_params = {
      send_at: @deliver_at.to_i,
      to: [User.find(2).email, User.find(3).email]
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(
      from: "#{@chapter.book.author} <bungomail@notsobad.jp>",
      to: @subscription.user.email,
      subject: @chapter.book.title
    )
  end
end
