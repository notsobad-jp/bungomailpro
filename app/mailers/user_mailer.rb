class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @user = User.find user.id
    @url  = URI.join(root_url, "auth?token=#{@user.magic_login_token}")

    xsmtp_api_params = { category: 'login' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(to: @user.email, subject: '【ブンゴウメール】ログイン用URL')
    logger.info "[LOGIN] Login mail sent to #{@user.id}"
  end

  def chapter_email
    @subscription = params[:subscription]
    @comment = @subscription.current_comment
    send_at = Time.zone.parse(@subscription.next_delivery_date.to_s).change(hour: @subscription.delivery_hour)

    # 実際の配信先（PROプランのユーザー）がいない場合は処理をスキップ
    return if (deliverable_emails = @subscription.deliverable_emails).blank?

    xsmtp_api_params = {
      send_at: send_at.to_i,
      to: deliverable_emails,
      category: 'chapter'
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    # チャネルに送信元アドレス・送信者名が設定されていればそっちを適用する
    if (from_name = @subscription.channel.from_name)
      subject = "#{@subscription.current_book.author.tr(',', '、')}『#{@subscription.current_book.title}』（#{@subscription.next_chapter.index}/#{@subscription.current_book.chapters_count}） - #{@subscription.channel.title}"
    else
      from_name = "#{@subscription.current_book.author.delete(' ').tr(',', '、')}（ブンゴウメール）"
      subject = "#{@subscription.current_book.title}（#{@subscription.next_chapter.index}/#{@subscription.current_book.chapters_count}） - #{@subscription.channel.title}"
    end
    from_email = @subscription.channel.from_email || 'bungomail@notsobad.jp'

    mail(
      from: "#{from_name} <#{from_email}>",
      to: 'noreply@notsobad.jp', # xsmtpパラメータで上書きされるのでこのtoはダミー
      subject: subject,
      reply_to: 'info@notsobad.jp'
    )
    logger.info "[SCHEDULED] channel:#{@subscription.channel.id}, chapter:#{@subscription.next_chapter.book_id}-#{@subscription.next_chapter.index}, send_at:#{send_at}, to:#{@subscription.user_id}"
  end


  def bungo_email
    @subscription = params[:subscription]
    @comment = @subscription.current_comment
    send_at = Time.zone.parse(@subscription.next_delivery_date.to_s).change(hour: @subscription.delivery_hour)

    xsmtp_api_params = {
      send_at: send_at.to_i,
      to: ['bungomail-text@notsobad.jp', 'lkxhb1yn0m.6fnhsbevhylj4@blog.hatena.ne.jp'], # 公式グループアドレスと公式ブログに配信
      category: 'chapter'
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    from_name = "#{@subscription.current_book.author.delete(' ').tr(',', '、')}（ブンゴウメール）"
    subject = "#{@subscription.current_book.title}（#{@subscription.next_chapter.index}/#{@subscription.current_book.chapters_count}） - #{@subscription.channel.title}"
    from_email = 'bungomail@notsobad.jp'

    mail(
      from: "#{from_name} <#{from_email}>",
      to: 'noreply@notsobad.jp', # xsmtpパラメータで上書きされるのでこのtoはダミー
      subject: subject,
      reply_to: 'info@notsobad.jp'
    )
    logger.info "[SCHEDULED][GROUP] channel:#{@subscription.channel.id}, chapter:#{@subscription.next_chapter.book_id}-#{@subscription.next_chapter.index}, send_at:#{send_at}, to:#{@subscription.user_id}"
  end


  def notification_email
    @notification = params[:notification]
    send_at = params[:date]

    xsmtp_api_params = {
      send_at: send_at.to_i,
      to: params[:target],
      category: 'notification'
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    from_name = "ブンゴウメール編集部"
    from_email = 'bungomail@notsobad.jp'

    mail(
      from: "#{from_name} <#{from_email}>",
      to: 'noreply@notsobad.jp', # xsmtpパラメータで上書きされるのでこのtoはダミー
      subject: @notification.title,
      reply_to: 'info@notsobad.jp'
    )
    logger.info "[NOTIFICATION] notification: #{@notification.id}, send_at: #{send_at}"
  end
end
