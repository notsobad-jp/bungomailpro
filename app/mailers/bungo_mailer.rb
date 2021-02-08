class BungoMailer < ApplicationMailer
  def chapter_email
    @campaign = params[:campaign]
    @book = @campaign.campaign_group.book
    @word_count = @campaign.content.gsub(" ", "").length

    mail(to: "info@notsobad.jp", from: "#{@book.author_name}（ブンゴウメール）", subject: @campaign.title)
  end
end
