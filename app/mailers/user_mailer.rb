class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def magic_login_email(user)
    @user = user
    @url  = URI.join(root_url, "/#{I18n.locale}/auth?token=#{@user.magic_login_token}")

    xsmtp_api_params = { category: 'login' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(to: @user.email, subject: '[BungoMail] Signin URL')
    logger.info "[LOGIN] Login mail sent to #{@user.id}"
  end

  def activation_needed_email(user)
    @user = user
    @url  = URI.join(root_url, "/users/#{user.activation_token}/activate")
    mail(to: user.email, subject: "【ブンゴウメール】アカウント認証")
  end
end
