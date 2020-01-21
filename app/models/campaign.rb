# == Schema Information
#
# Table name: campaigns
#
#  id                :bigint(8)        not null, primary key
#  content           :text             not null
#  send_at           :datetime         not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  campaign_group_id :bigint(8)        default(1), not null
#  sendgrid_id       :integer
#
# Indexes
#
#  index_campaigns_on_campaign_group_id  (campaign_group_id)
#  index_campaigns_on_sendgrid_id        (sendgrid_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_group_id => campaign_groups.id)
#

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

  private

  def plain_content
    word_count = content.gsub(" ", "").length
    <<-EOS
      （#{word_count.to_s(:delimited)}字。目安の読了時間：#{word_count.quo(500).ceil}分）

      #{content}

      =========================
      ハッシュタグ「#ブンゴウメール」をつけて感想をつぶやこう！　
      #{twitter_share_url}

      ■Twitterでみんなの感想を見る：https://goo.gl/rgfoDv
      ■ブンゴウメール公式サイト：https://bungomail.com
      ■青空文庫でこの作品を読む：#{campaign_group.book.aozora_file_url}
      ■運営へのご支援はこちら： https://www.buymeacoffee.com/bungomail
      ■月末まで一時的に配信を停止： https://forms.gle/d2gZZBtbeAEdXySW9

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

  def twitter_share_url
    long_url = CGI.escape("https://twitter.com/intent/tweet?url=https%3A%2F%2Fbungomail.com%2F&hashtags=ブンゴウメール&text=#{send_at.month}月は%20%23#{campaign_group.book.author.delete(' ')}%20%23#{campaign_group.book.title}%20を配信中！")

    uri = URI.parse("https://api-ssl.bitly.com/v3/shorten?access_token=#{ENV['BITLY_ACCESS_TOKEN']}&longUrl=#{long_url}")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    res = https.start {
      https.get(uri.request_uri)
    }
    JSON.parse(res.body)['data']['url']
  end

  def unsubscribe_url
    case self.campaign_group.list_id
    when 9399756 # ブンゴウメール配信リスト
      "https://goo.gl/forms/kVz3fE9HdDq5iuA03"
    when 10315463 # ドグラ・マグラ配信リスト
      "https://bungomail.com/campaigns/dogramagra"
    end
  end
end
