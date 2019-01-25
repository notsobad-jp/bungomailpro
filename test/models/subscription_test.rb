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
#  token              :string           not null
#

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)
  end

  ########################################################################
  # current_chapter
  ########################################################################
  ## 配信開始前
  test "current_chapter_when_not_started" do
    sub = subscriptions(:user1_channel1)

    # 配信時間前
    travel_to(Time.zone.now.change(hour: 6)) do
      assert_equal chapters(:book1_chapter1), sub.current_chapter
    end

    # 配信時間後
    travel_to(Time.zone.now.change(hour: 10)) do
      assert_equal chapters(:book1_chapter1), sub.current_chapter
    end
  end

  ## 配信完了後
  test "current_chapter_when_finished" do
    sub = subscriptions(:user2_channel1)
    assert_nil sub.current_chapter
  end

  ## 配信中（配信時間前）
  test "current_chapter_before_delivery_time" do
    travel_to(Time.zone.now.change(hour: 6)) do
      sub = subscriptions(:user1_channel2)
      assert_equal chapters(:book2_chapter1), sub.current_chapter
    end
  end

  ## 配信中（配信時間後）
  test "current_chapter_after_delivery_time" do
    travel_to(Time.zone.now.change(hour: 10)) do
      sub = subscriptions(:user1_channel2)
      assert_equal chapters(:book2_chapter2), sub.current_chapter
    end
  end


  ########################################################################
  # prev_chapter
  ########################################################################
  test "prev_chapter" do
    # index > 1のとき
    # 2冊めのindex:1
    # 1冊目のindex:1
    # 配信完了後
  end

  test "set_next_chapter" do
  end
end
