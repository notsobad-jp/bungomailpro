class Campaign < ApplicationRecord
  belongs_to :campaign_group
  include Sendgrid

  def create_draft
    res = self.call(path: "campaigns", params: sendgrid_params)
    self.update(sendgrid_id: res["id"])
  end

  def schedule
    self.call(path: "campaigns/#{self.sendgrid_id}/schedules", params: { send_at: self.send_at.to_i })
  end

  def deliver
    self.call(path: "campaigns/#{self.sendgrid_id}/schedules/now")
  end

  def unschedule
    self.call(method: :delete, path: "campaigns/#{self.sendgrid_id}/schedules")
  end

  def delete_campaign
    self.call(method: :delete, path: "campaigns/#{self.sendgrid_id}")
    self.delete
  end

  def create_md
    slug = self.send_at.strftime('%Y%m%d%H%M%S')
    File.open("tmp/blog/#{slug}.md", "w") do |f|
      f.puts(markdown_content)
    end
  end

  private

  def markdown_content
    <<~EOS
      ---
      title: #{title}
      date: #{send_at.strftime("%m/%d/%Y %H:%M:%S")}
      author: #{campaign_group.book.author_name}
      ---

      #{plain_content}
    EOS
  end

  def plain_content
    word_count = content.gsub(" ", "").length
    <<~EOS
      （#{word_count.to_s(:delimited)}字。目安の読了時間：#{word_count.quo(500).ceil}分）

      #{content}

      =========================
      ハッシュタグ「#ブンゴウメール」をつけて感想をつぶやこう！　
      #{campaign_group.twitter_share_url}

      ■Twitterでみんなの感想を見る：https://goo.gl/rgfoDv
      ■ブンゴウメール公式サイト：https://bungomail.com
      ■青空文庫でこの作品を読む：#{campaign_group.book.aozora_file_url}
      ■運営へのご支援はこちら： https://www.buymeacoffee.com/bungomail
      ■月末まで一時的に配信を停止： https://bungomail.com/unsubscribe

      -------
      配信元: ブンゴウメール編集部
      NOT SO BAD, LLC.
      Web: https://bungomail.com
      配信停止：[unsubscribe]
    EOS
  end

  def html_content
    text = plain_content
    URI.extract(text, ["http", "https"]).uniq.each do |url|
      text.gsub!(url, "<a target='_blank' href='#{url}'>#{url}</a>")
    end
    text.gsub!(/(\r\n|\r|\n)/, "<br />")
  end

  def sendgrid_params
    {
      title: title,
      subject: title,
      sender_id: self.campaign_group.sender_id,
      list_ids: [ self.campaign_group.list_id ],
      custom_unsubscribe_url: unsubscribe_url,
      html_content: html_content,
      plain_content: plain_content
    }
  end

  def unsubscribe_url
    case self.campaign_group.list_id
    when 9399756 # ブンゴウメール配信リスト
      "https://bungomail.com/unsubscribe"
    when 10315463 # ドグラ・マグラ配信リスト
      "https://bungomail.com/campaigns/dogramagra"
    end
  end
end
