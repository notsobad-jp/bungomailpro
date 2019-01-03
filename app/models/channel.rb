# == Schema Information
#
# Table name: channels
#
#  id                :bigint(8)        not null, primary key
#  token             :string           not null
#  user_id           :bigint(8)        not null
#  next_chapter_id   :bigint(8)
#  last_chapter_id   :bigint(8)
#  title             :string           not null
#  description       :text
#  deliver_at        :integer          default(8)
#  public            :boolean          default(FALSE), not null
#  books_count       :integer          default(0), not null
#  subscribers_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Channel < ApplicationRecord
  belongs_to :user
  belongs_to :next_chapter, class_name: 'Chapter', foreign_key: 'next_chapter_id', optional: true
  belongs_to :last_chapter, class_name: 'Chapter', foreign_key: 'last_chapter_id', optional: true
  has_many :channel_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :channel_books
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true

  before_create do
    self.token = SecureRandom.hex(10)
  end

  after_create do
    self.subscriptions.create!(user_id: self.user_id)
  end


  def add_book(book)
    self.channel_books.create_with(index: self.current_index + 1).find_or_create_by(book_id: book.id)
  end

  def current_index
    self.channel_books.maximum(:index) || 0
  end

  def import(from_channel)
    existing_books = self.channel_books.pluck(:book_id)
    channel_books = []
    from_channel.channel_books.each.with_index(self.current_index + 1) do |channel_book, index|
      next if existing_books.include? channel_book.book_id
      channel_books << ChannelBook.new(channel_id: self.id, book_id: channel_book.book_id, index: index)
    end

    ActiveRecord::Base.transaction do
      ChannelBook.import! channel_books
      Channel.reset_counters(self.id, :channel_books)
    end
  end
end
