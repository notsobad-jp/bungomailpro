class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @user = User.find user.id
    @url  = URI.join(root_url, "auth?token=#{@user.magic_login_token}")

    mail(to: @user.email, subject: "Magic Login")
  end


  def deliver_chapter
    @delivery = params[:delivery]
    @user = @delivery.user

    mail(to: @user.email, subject: "【ブンゴウメール】#{@delivery.book.title}（#{@delivery.index}/#{@delivery.last_index}）")
  end
end
