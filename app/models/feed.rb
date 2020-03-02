# == Schema Information
#
# Table name: feeds
#
#  id               :bigint(8)        not null, primary key
#  content          :text
#  index            :integer          default(1), not null
#  scheduled        :boolean          default(FALSE)
#  send_at          :date
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assigned_book_id :uuid             not null
#
# Indexes
#
#  index_feeds_on_assigned_book_id  (assigned_book_id)
#
# Foreign Keys
#
#  fk_rails_...  (assigned_book_id => assigned_books.id)
#

class Feed < ApplicationRecord
  belongs_to :assigned_book

  # 配信時間とTZの時差を調整して、UTCとのoffsetを算出（単位:minutes）
  def utc_offset
    user = self.assigned_book.user
    # UTC00:00から配信時間までの分数（必ずプラス）
    ## "08:10" => [8, 10] => [480, 10] => +490(minutes)
    delivery_offset = user.delivery_time.split(":").map(&:to_i).zip([60, 1]).map{|a,b| a*b }.sum

    # UTCとユーザーTimezoneの差分（プラスマイナスどちらもありえる）
    timezone_offset = ActiveSupport::TimeZone.new(user.timezone).utc_offset

    # offsetの結果、前日や翌日に日がまたぐ場合もいい感じに調整する（e.g. -01:00 => 23:00, 27:00 => 03:00）
    (delivery_offset - timezone_offset) % (24 * 60)
  end
end
