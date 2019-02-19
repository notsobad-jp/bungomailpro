# == Schema Information
#
# Table name: users
#
#  id                           :uuid             not null, primary key
#  email                        :string           not null
#  crypted_password             :string
#  salt                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  magic_login_token            :string
#  magic_login_token_expires_at :datetime
#  magic_login_email_sent_at    :datetime
#  remember_me_token            :string
#  remember_me_token_expires_at :datetime
#

require 'net/http'
require 'uri'
require 'json'

class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :subscriptions, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_one :charge, dependent: :destroy
  MAX_SUBSCRIPTIONS_COUNT = 3

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :subscriptions, length: { maximum: MAX_SUBSCRIPTIONS_COUNT }

  after_create do
    channels.create!(title: 'マイチャネル', default: true)
  end

  def default_channel
    channels.find_by(default: true) || channels.first
  end

  def display_name
    profile ? profile['displayName'] : id
  end

  def pro?
    # TODO: 2019年2月末まではベータ版で全員PRO扱い。それ以降は購読ステータスで判断する
    Time.current < Time.zone.parse('2019-03-01') || self.charge.try(:active?)
  end

  def profile_image_url
    hash = Digest::MD5.hexdigest(email.downcase)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  def profile
    hash = Digest::MD5.hexdigest(email.downcase)
    uri = URI.parse "https://ja.gravatar.com/#{hash}.json"
    json = Net::HTTP.get(uri)

    JSON.parse(json)['entry'].try(:first)
  end

  def subscribe(channel)
    params = if channel.streaming?
               { user_id: id }
             else
               {
                 user_id: id,
                 next_delivery_date: Time.zone.tomorrow,
                 current_book_id: channel.channel_books.first.book_id,
                 next_chapter_index: 1
               }
             end
    subscriptions.create_with(params).find_or_create_by!(channel_id: channel.id)
  end

  def subscriptionable?
    subscriptions.where.not(next_delivery_date: nil).size < MAX_SUBSCRIPTIONS_COUNT
  end
end
