class BungoMailer < ApplicationMailer
  def chapter_email
    @chapter = params[:chapter]
    @book = @chapter.book_assignment.book
    @channel = @chapter.book_assignment.channel
    @word_count = @chapter.content.gsub(" ", "").length

    sender_name = envelope_display_name("#{@book.author_name}（ブンゴウメール）")
    send_to = @channel.send_to || @channel.user.email

    mail(to: send_to, from: "#{sender_name} <bungomail@notsobad.jp>", subject: @chapter.title)
  end

  private

  # メール送信名をRFCに準拠した形にフォーマット
  ## http://kotaroito.hatenablog.com/entry/2016/09/23/103436
  def envelope_display_name(display_name)
    name = display_name.dup

    # Special characters
    if name && name =~ /[\(\)<>\[\]:;@\\,\."]/
      # escape double-quote and backslash
      name.gsub!(/\\/, '\\')
      name.gsub!(/"/, '\"')

      # enclose
      name = '"' + name + '"'
    end

    name
  end
end
