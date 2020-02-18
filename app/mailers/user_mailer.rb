class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def magic_login_email(user)
    @user = User.find user.id
    @url  = URI.join(root_url, "auth?token=#{@user.magic_login_token}")

    xsmtp_api_params = { category: 'login' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(to: @user.email, subject: '【ブンゴウメール】ログイン用URL')
    logger.info "[LOGIN] Login mail sent to #{@user.id}"
  end

  def feed_email(feed)
    @feed = feed
    send_at = Time.zone.parse(@feed.send_at.to_s).change(hour: 7)

    # TODO: 課金ユーザーじゃない場合はスキップ
    # return if (deliverable_emails = @subscription.deliverable_emails).blank?

    xsmtp_api_params = {
      send_at: send_at.to_i,
      to: [@feed.assigned_book.user.email],
      category: ['gutenberg']
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    from_email = 'bungomail@notsobad.jp'
    from_name = "#{@feed.assigned_book.guten_book.author} (BungoMail)"
    subject = @feed.title

    mail(
      from: "#{from_name} <#{from_email}>",
      to: 'noreply@notsobad.jp', # xsmtpパラメータで上書きされるのでこのtoはダミー
      subject: subject,
      reply_to: 'info@notsobad.jp'
    )
    @feed.update(scheduled: true)
    logger.info "[SCHEDULED] feed:#{@feed.id}"
  end
end
