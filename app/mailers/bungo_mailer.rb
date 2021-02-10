class BungoMailer < ApplicationMailer
  def chapter_email
    @campaign = params[:campaign]
    @book = @campaign.campaign_group.book
    @word_count = @campaign.content.gsub(" ", "").length
    sender_name = envelope_display_name("#{@book.author_name}（ブンゴウメール）")

    mail(to: "info@notsobad.jp", from: "#{sender_name} <bungomail@notsobad.jp>", subject: @campaign.title)
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
