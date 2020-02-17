# == Schema Information
#
# Table name: users
#
#  id                           :uuid             not null, primary key
#  crypted_password             :string
#  email                        :string           not null
#  magic_login_email_sent_at    :datetime
#  magic_login_token            :string
#  magic_login_token_expires_at :datetime
#  remember_me_token            :string
#  remember_me_token_expires_at :datetime
#  salt                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
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
  has_one :charge, dependent: :destroy
  has_many :assigned_books, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }


  def assign_book
    # LIKE > 30 : 1094冊
    # LIKE > 100 : 245冊（最初はおもしろそうなやつを）
    ids = ActiveRecord::Base.connection.select_values("select guten_book_id from guten_books_subjects where subject_id IN (select id from subjects where LOWER(id) LIKE '%fiction%')")
    GutenBook.where(id: ids, language: 'en', rights: 'Public domain in the USA.', words_count: 5000..40000).where("downloads > ?", 100).order(Arel.sql("RANDOM()")).first
  end

  def assign_book_and_deliver_first_feed
    book = self.assign_book
    assigned_book = self.assigned_books.create(guten_book_id: book.id)
    feeds = assigned_book.set_feeds
    first_feed = Feed.find(feeds.ids.min)
    UserMailer.feed_email(first_feed).deliver
  end
end
