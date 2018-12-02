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
    mail(
      from: "夏目漱石 <bungomail@notsobad.jp>",
      to: 'tomomichi.onishi@gmail.com',
      subject: "【ブンゴウメール】夢十夜",
      send_at: @deliver_at.to_i
    )
  end
end
