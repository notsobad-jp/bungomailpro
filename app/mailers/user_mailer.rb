class UserMailer < ApplicationMailer

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

    mail(to: @user.email, subject: "【ブンゴウメール】ログイン用URL")
    Logger.new(STDOUT).info "[LOGIN] Login mail sent to #{@user.id}"
  end


  def chapter_email
    @subscription = params[:subscription]
    @channel = @subscription.channel
    @chapter = @subscription.next_chapter
    @book = @subscription.current_book
    @notification = Notification.find_by(date: Time.current)
    send_at = Time.current.change(hour: @subscription.delivery_hour)

    xsmtp_api_params = {
      send_at: send_at.to_i,
      # to: @channel.subscribers.pluck(:email),
      category: 'chapter'
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(
      from: "#{@book.author}（ブンゴウメール） <bungomail@notsobad.jp>",
      to: @subscription.user.email,
      subject: "#{@book.title}（#{@chapter.index}/#{@book.chapters_count}）【#{@channel.title}】"
    )
    Logger.new(STDOUT).info "[SCHEDULED] channel:#{@channel.id}, chapter:#{@chapter.book_id}-#{@chapter.index}, send_at:#{send_at}, to:#{@subscription.user_id}"
  end
end
