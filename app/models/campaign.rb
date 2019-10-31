# == Schema Information
#
# Table name: campaigns
#
#  id          :bigint(8)        not null, primary key
#  content     :text             not null
#  send_at     :datetime         not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  book_id     :bigint(8)        not null
#  sendgrid_id :integer
#
# Indexes
#
#  index_campaigns_on_book_id      (book_id)
#  index_campaigns_on_sendgrid_id  (sendgrid_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#

class Campaign < ApplicationRecord
  belongs_to :book
  include Sendgrid

  DEFAULT_SENDER_ID = 611140
  DEFAULT_LIST_ID = 9399756


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
      （#{word_count}字。目安の読了時間：#{word_count.quo(500).ceil}分）

      #{content}

      =========================
      ハッシュタグ「#ブンゴウメール」をつけて感想をつぶやこう！　
      #{twitter_share_url}

      ■Twitterでみんなの感想を見る：https://goo.gl/rgfoDv
      ■ブンゴウメール公式サイト：https://bungomail.com
      ■青空文庫でこの作品を読む：#{book.aozora_file_url}
      ■運営へのご支援はこちら： https://www.buymeacoffee.com/bungomail

      メール配信の停止はこちら： [unsubscribe]

      -------
      配信元: ブンゴウメール編集部
      NOT SO BAD, LLC.
      Web: https://bungomail.com
      Mail: info@notsobad.jp
    EOS
  end

  def sendgrid_params
    {
      title: title,
      subject: title,
      sender_id: DEFAULT_SENDER_ID,
      list_ids: [ DEFAULT_LIST_ID ],
      custom_unsubscribe_url: unsubscribe_url,
      html_content: plain_content.gsub(/(\r\n|\r|\n)/, "<br />"),
      plain_content: plain_content
    }
  end

  def twitter_share_url
    long_url = CGI.escape("https://twitter.com/intent/tweet?url=https%3A%2F%2Fbungomail.com%2F&hashtags=ブンゴウメール&text=#{send_at.month}月は%20%23#{book.author.delete(' ')}%20%23#{book.title}%20を配信中！")

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
    "https://goo.gl/forms/kVz3fE9HdDq5iuA03"
  end
end
