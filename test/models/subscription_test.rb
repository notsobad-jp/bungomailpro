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
  # 配信開始前
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

  # 配信完了後
  test "current_chapter_when_finished" do
    sub = subscriptions(:user2_channel1)
    assert_nil sub.current_chapter
  end

  # 配信中（配信時間前）
  test "current_chapter_before_delivery_time" do
    travel_to(Time.zone.now.change(hour: 6)) do
      sub = subscriptions(:user1_channel2)
      assert_equal chapters(:book2_chapter2), sub.current_chapter
    end
  end

  # 配信中（配信時間後）
  test "current_chapter_after_delivery_time" do
    travel_to(Time.zone.now.change(hour: 10)) do
      sub = subscriptions(:user1_channel2)
      assert_equal chapters(:book2_chapter3), sub.current_chapter
    end
  end


  ########################################################################
  # prev_chapter
  ########################################################################
  # index > 1のとき
  test "prev_chapter_with_index>1" do
    sub = subscriptions(:user1_channel2)
    assert_equal chapters(:book2_chapter2), sub.prev_chapter
  end

  # 2冊めのindex:1
  test "prev_chapter_with_2nd_book_index_1" do
    sub = subscriptions(:user2_channel2)
    assert_equal chapters(:book2_chapter3), sub.prev_chapter
  end

  # 1冊目のindex:1
  test "prev_chapter_with_1st_book_index_1" do
    sub = subscriptions(:user1_channel1)
    assert_nil sub.prev_chapter
  end

  # 配信完了後
  test "prev_chapter_with_finished_channel" do
    sub = subscriptions(:user2_channel1)
    assert_nil sub.prev_chapter
  end


  ########################################################################
  # set_next_chapter
  ########################################################################
  # 同じ本で次のchapterが存在すればそれをセット
  test "set_next_chapter_when_next_chapter_exists" do
    travel_to(Time.zone.now.change(day: 1)) do
      sub = subscriptions(:user1_channel1)
      sub.set_next_chapter

      assert_equal 2, sub.next_chapter_index
      assert_equal Time.zone.today.change(day: 2), sub.next_delivery_date
      assert_equal books(:book1), sub.current_book
    end
  end

  # 次のchapterがなければ、次の本を探してindex:1でセット
  test "set_next_chapter_when_next_book_exists" do
    travel_to(Time.zone.now.change(day: 1)) do
      sub = subscriptions(:user1_channel2)
      sub.set_next_chapter

      assert_equal 1, sub.next_chapter_index
      assert_equal Time.zone.today.change(day: 2), sub.next_delivery_date
      assert_equal books(:book1), sub.current_book
    end
  end

  # next_channel_bookもなければ配信停止状態にする
  test "set_next_chapter_when_no_next_exists" do
    travel_to(Time.zone.now.change(day: 1)) do
      sub = subscriptions(:user3_channel1)
      sub.set_next_chapter

      assert_nil sub.next_chapter_index
      assert_nil sub.next_delivery_date
      assert_nil sub.current_book
    end
  end

  # すでに配信停止の状態なら処理をスキップ
  test "set_next_chapter_when_already_finished" do
    travel_to(Time.zone.now.change(day: 1)) do
      sub = subscriptions(:user2_channel1)
      sub.set_next_chapter

      assert_nil sub.next_chapter_index
      assert_nil sub.next_delivery_date
      assert_nil sub.current_book
    end
  end

  # 翌日が31日の場合はスキップ
  test "set_next_chapter_when_tomorrow_31st" do
    travel_to('2019-01-30') do
      sub = subscriptions(:user1_channel1)
      sub.set_next_chapter

      assert_equal 2, sub.next_chapter_index
      assert_equal Date.parse('2019-02-01'), sub.next_delivery_date
      assert_equal books(:book1), sub.current_book
    end
  end


  ########################################################################
  # not_started
  ########################################################################
  # 配信前
  test "not_started_when_true" do
    sub = subscriptions(:user1_channel1)
    assert sub.not_started?
  end

  # 配信後
  test "not_started_when_false" do
    sub = subscriptions(:user1_channel2)
    assert !sub.not_started?
  end


  ########################################################################
  # create_feed
  ########################################################################
  test "create_feed" do
    sub = subscriptions(:user1_channel1)
    sub.create_feed
    assert_equal 1, sub.feeds.count
  end
end
