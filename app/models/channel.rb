# == Schema Information
#
# Table name: channels
#
#  id                :bigint(8)        not null, primary key
#  token             :string           not null
#  user_id           :bigint(8)        not null
#  title             :string           not null
#  description       :text
#  public            :boolean          default(FALSE), not null
#  books_count       :integer          default(0), not null
#  subscribers_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  default           :boolean          default(FALSE), not null
#

class Channel < ApplicationRecord
  belongs_to :user
  has_many :channel_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :channel_books
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true
  validates :default, presence: true

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

  def next_book(current_book_id)
    current_index = self.channel_books.find_by(book_id: current_book_id).index
    self.channel_books.where('index > ?', current_index).first.try(:book)
  end

  def owner_subscription
    self.subscriptions.find_by(user_id: self.user_id)
  end
end
