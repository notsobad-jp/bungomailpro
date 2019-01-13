# == Schema Information
#
# Table name: users
#
#  id                           :bigint(8)        not null, primary key
#  email                        :string           not null
#  token                        :string           not null
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

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :channels, length: { maximum: 3 }, on: :update
  validates :subscriptions, length: { maximum: 3 }, on: :update

  before_create do
    self.token = SecureRandom.hex(10)
  end

  after_create do
    self.channels.create!(title: 'マイチャネル', default: true)
  end


  def default_channel
    self.channels.find_by(default: true) || self.channels.first
  end

  def display_name
    self.profile ? self.profile['displayName'] : self.token
  end

  def profile_image_url
    hash = Digest::MD5.hexdigest(self.email.downcase)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  def profile
    hash = Digest::MD5.hexdigest(self.email.downcase)
    uri = URI.parse "https://ja.gravatar.com/#{hash}.json"
    json = Net::HTTP.get(uri)

    JSON.parse(json)['entry'].try(:first)
  end

  def subscribe(channel)
    self.subscriptions.create!(
      user_id: self.id,
      channel_id: channel.id,
      next_delivery_date: Time.zone.tomorrow, #TODO: 月初開始の場合分け
      current_book_id: channel.channel_books.first.book_id,
      next_chapter_index: 1
    )
  end
end
