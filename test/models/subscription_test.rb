# == Schema Information
#
# Table name: subscriptions
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)        not null
#  channel_id         :bigint(8)        not null
#  current_book_id    :bigint(8)
#  next_chapter_index :integer
#  delivery_hour      :integer          default(8), not null
#  next_delivery_date :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)
    @sub = subscriptions(:user1_with_books)
  end

  test "current_chapter" do
    # 配信開始前
    assert_equal chapters(:book1_chapter1), @sub.current_chapter
    # 配信完了後
    # 配信中（配信時間前）
    # 配信中（配信時間後）
  end

  test "prev_chapter" do
    # index > 1のとき
    # 2冊めのindex:1
    # 1冊目のindex:1
    # 配信完了後
  end

  test "set_next_chapter" do
  end
end
