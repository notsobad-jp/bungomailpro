# == Schema Information
#
# Table name: campaigns
#
#  id            :bigint(8)        not null, primary key
#  plain_content :text             not null
#  send_at       :datetime         not null
#  title         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sendgrid_id   :integer
#  user_id       :uuid             not null
#
# Indexes
#
#  index_campaigns_on_sendgrid_id  (sendgrid_id) UNIQUE
#  index_campaigns_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Campaign < ApplicationRecord
  include Sendgrid
  belongs_to :user

  BUNGO_SENDER_ID = 611140  # ブンゴウメール公式配信用sender（著者名表記）
  GENERAL_SENDER_ID = 612132  # 一般ユーザー配信用sender（「ブンゴウメール編集部」表記）


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

  def sender_id
    user.admin? ? BUNGO_SENDER_ID : GENERAL_SENDER_ID
  end

  def sendgrid_params
    {
      title: title,
      subject: title,
      sender_id: sender_id,
      list_ids: [ user.list_id ],
      custom_unsubscribe_url: unsubscribe_url,
      plain_content: plain_content
    }
  end

  def unsubscribe_url
    "https://bungomail.com/lists/#{user.list_id}/unsubscribe"
  end
end
