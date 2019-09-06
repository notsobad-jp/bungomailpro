# == Schema Information
#
# Table name: campaigns
#
#  id                     :bigint(8)        not null, primary key
#  custom_unsubscribe_url :string
#  html_content           :text
#  plain_content          :text
#  subject                :string           not null
#  title                  :string           not null
#  list_id                :integer
#  sender_id              :integer
#  sendgrid_id            :integer
#
# Indexes
#
#  index_campaigns_on_sendgrid_id  (sendgrid_id)
#

class Campaign < ApplicationRecord
  API_BASE_URL = 'https://api.sendgrid.com/v3/'

  # 汎用APIcall
  def self.call(method: :post, path: "", params: nil)
    uri = URI.join(API_BASE_URL, path)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri.path)
    req["authorization"] = "Bearer #{ENV['SENDGRID_API_KEY']}"
    req["content-type"] = 'application/json'
    req.body = params.to_json if params

    http.request(req)
  end

  # campaign作成
  def create_draft
    self.class.call(path: "campaigns", params: JSON.parse(self.to_json))
  end

  def schedule(send_at)
    self.class.call(path: "campaigns/#{self.id}/schedules", params: { send_at: Time.zone.parse(send_at).to_i })
  end

  def deliver
    self.class.call(path: "campaigns/#{self.id}/schedules/now")
  end

  def unschedule
    self.class.call(method: :delete, path: "campaigns/#{self.id}/schedules")
  end

  def delete_campaign
    self.class.call(method: :delete, path: "campaigns/#{self.id}")
  end
end
