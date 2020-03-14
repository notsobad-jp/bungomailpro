# == Schema Information
#
# Table name: campaign_groups
#
#  id         :bigint(8)        not null, primary key
#  count      :integer          not null
#  start_at   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint(8)        not null
#  list_id    :integer          not null
#  sender_id  :integer          not null
#
# Indexes
#
#  index_campaign_groups_on_book_id  (book_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#

class CampaignGroup < ApplicationRecord
  belongs_to :book
  has_many :campaigns, -> { order(:send_at) }, dependent: :destroy

  def import_campaigns
    campaigns = []
    text = self.book.aozora_file_text[0]
    contents = Book.split_text(text: text, count: self.count)
    send_at = self.start_at

    contents.each.with_index(1) do |content, index|
      title = "#{self.book.title}（#{index}/#{contents.count}）"
      campaigns << Campaign.new(
        title: title,
        content: content,
        send_at: send_at,
        campaign_group_id: self.id
      )
      send_at += 1.day
    end
    Campaign.import campaigns
  end

  def schedule
    self.campaigns.each do |campaign|
      next if campaign.send_at < Time.zone.now

      campaign.create_draft
      campaign.schedule
      # campaign.deliver
      p "Scheduled #{campaign.title}"
      sleep 1
    end
  end
end
