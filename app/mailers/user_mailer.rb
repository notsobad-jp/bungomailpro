class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @user = User.find user.id
    @url  = "http://localhost:3000/auth?token=" + @user.magic_login_token

    mail(to: @user.email, subject: "Magic Login")
  end
end
