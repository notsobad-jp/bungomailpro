# == Schema Information
#
# Table name: users
#
#  id                             :uuid             not null, primary key
#  category(IN (admin partner))   :string
#  crypted_password               :string
#  email                          :string           not null
#  magic_login_email_sent_at      :datetime
#  magic_login_token              :string
#  magic_login_token_expires_at   :datetime
#  pixela_logging                 :boolean          default(FALSE)
#  remember_me_token              :string
#  remember_me_token_expires_at   :datetime
#  salt                           :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_users_on_email              (email) UNIQUE
#  index_users_on_magic_login_token  (magic_login_token)
#  index_users_on_remember_me_token  (remember_me_token)
#

require 'net/http'
require 'uri'
require 'json'

class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :subscriptions, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_one :charge, dependent: :destroy
  MAX_SUBSCRIPTIONS_COUNT = 5

  ALTEREGO_ID = 'bb378768-e59a-47d8-bd18-f25bb116340b'.freeze
  NOTSOBAD_ID = 'be7a3676-004e-4b0d-b428-e62315798e22'.freeze

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validate :subscriptions_count, on: :update

  def default_channel
    channels.find_by(default: true) || channels.first
  end

  def display_name
    profile ? profile['displayName'] : id
  end

  def max_subscriptions_count
    pro? ? MAX_SUBSCRIPTIONS_COUNT : 1
  end

  def pixela_id
    "a#{id[0..14]}"
  end

  def pixela_url
    "#{Pixela::PIXELA_BASE_URL}/#{pixela_id}"
  end

  def pro?
    charge.try(:active?) || %w(admin partner).include?(category)
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
    subscriptions.size < max_subscriptions_count
  end

  private

  def subscriptions_count
    errors.add(:subscriptions, "is too long") unless self.subscriptions.count <= max_subscriptions_count
  end
end
