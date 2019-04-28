# == Schema Information
#
# Table name: channels
#
#  id                                    :uuid             not null, primary key
#  books_count                           :integer          default(0), not null
#  default                               :boolean          default(FALSE), not null
#  description                           :text
#  from_email                            :string
#  from_name                             :string
#  hashtag                               :string
#  status(IN (private public streaming)) :string           default("private"), not null
#  subscribers_count                     :integer          default(0), not null
#  title                                 :string           not null
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  user_id                               :uuid             not null
#
# Indexes
#
#  index_channels_on_user_id              (user_id)
#  index_channels_on_user_id_and_default  (user_id,default) UNIQUE WHERE ("default" = true)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Channel < ApplicationRecord
  belongs_to :user
  has_many :channel_books, -> { order(:index) }, dependent: :destroy, inverse_of: :channel
  has_many :books, through: :channel_books
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  ALTEREGO_ID = '15ed0c75-553b-4b97-a142-9fb58f890883'.freeze
  URABANGUMI_ID = 'c0425db7-4991-4ba5-9322-3561691977f1'.freeze
  BUNGOMAIL_ID = '1418479c-d5a7-4d29-a174-c5133ca484b6'.freeze
  BUSINESSMODEL_ID = 'f99b2ad1-a4ed-4246-a805-eb181a4196c7'.freeze

  validates :title, presence: true
  validates :description, presence: { message: '：チャネルを公開する場合は「チャネルの説明」の入力も必須です' }, if: proc { |c| !c.private? }

  before_save do
    user.channels.update_all(default: false) if default
  end

  def add_book(book)
    channel_books.create_with(index: max_index + 1).find_or_create_by(book_id: book.id)
  end

  # streamingのときは、ownerのsubscriptionで配信時間などを決定
  def master_subscription
    subscriptions.find_by(user_id: user_id) if streaming?
  end

  def max_index
    channel_books.maximum(:index) || 0
  end

  # いま一番進んでる配信で配信中のbook_index。これより前の本は編集しちゃだめ。
  def latest_index
    sql = "SELECT MAX(channel_books.index) FROM subscriptions JOIN channel_books ON (subscriptions.channel_id = channel_books.channel_id AND subscriptions.current_book_id = channel_books.book_id) WHERE subscriptions.channel_id='#{id}'"
    ActiveRecord::Base.connection.select_value(sql) || 0 # 購読者なしのときはnilが来るので代わりに0を返す
  end

  # statusの確認メソッドを動的に定義
  %w[private public streaming].each do |value|
    define_method("#{value}?") do
      status == value
    end
  end
end
