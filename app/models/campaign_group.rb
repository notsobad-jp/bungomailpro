class CampaignGroup < ApplicationRecord
  belongs_to :book, class_name: 'AozoraBook'
  has_many :campaigns, -> { order(:send_at) }, dependent: :destroy

  LIST_ID = "9399756".freeze

  def import_campaigns
    campaigns = []
    contents = self.book.contents(count: self.count)
    send_at = self.start_at

    contents.each.with_index(1) do |content, index|
      title = "#{self.book.title}（#{index}/#{contents.count}）"
      campaigns << {
        title: title,
        content: content,
        send_at: send_at,
        campaign_group_id: self.id
      }
      send_at += 1.day
    end
    Campaign.insert_all campaigns
  end

  def schedule
    self.campaigns.each do |campaign|
      campaign.deliver_later
      # campaign.create_draft
      # campaign.schedule

      p "Scheduled #{campaign.title}"
      # sleep 1
    end
  end

  def twitter_short_url
    res = Bitly.call(path: 'shorten', params: { long_url: self.twitter_long_url })
    res["link"]
  end

  def twitter_long_url
    "https://twitter.com/intent/tweet?url=https%3A%2F%2Fbungomail.com%2F&hashtags=ブンゴウメール,青空文庫&text=#{start_at.month}月は%20%23#{book.author.delete(' ')}%20%23#{book.title}%20を配信中！"
  end
end
