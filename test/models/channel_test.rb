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

require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  def setup
    @channel_empty = channels(:empty)
    @channel_not_started = channels(:not_started)
    @channel_started = channels(:started)
  end


  test "publish" do
    @channel_not_started.publish

    assert_equal chapters(:book1_chapter1).id, @channel_not_started.next_chapter_id
    assert_equal true, channel_books(:not_started_book_1).delivered
  end

  test "set_next_chapter when next_chapter" do
    @channel_started.update!(next_chapter_id: chapters(:book1_chapter2).id, last_chapter_id: chapters(:book1_chapter1).id)
    @channel_started.set_next_chapter

    assert_equal chapters(:book1_chapter3).id, @channel_started.next_chapter_id
    assert_equal chapters(:book1_chapter2).id, @channel_started.last_chapter_id
  end

  test "set_next_chapter when !next_chapter && next_book" do
    @channel_started.update!(next_chapter_id: chapters(:book1_chapter3).id, last_chapter_id: chapters(:book1_chapter2).id)
    @channel_started.set_next_chapter

    assert_equal chapters(:book2_chapter1).id, @channel_started.next_chapter_id
    assert_equal chapters(:book1_chapter3).id, @channel_started.last_chapter_id
  end

  test "set_next_chapter when !next_chapter && !next_book" do
    @channel_started.update!(next_chapter_id: chapters(:book2_chapter2).id, last_chapter_id: chapters(:book2_chapter1).id)
    channel_book = channel_books(:started_book_2)
    channel_book.update!(delivered: true)
    @channel_started.set_next_chapter

    assert_nil @channel_started.next_chapter_id
    assert_equal chapters(:book2_chapter2).id, @channel_started.last_chapter_id
  end


  test "current_chapter before delivery" do
    @channel_started.update!(next_chapter_id: chapters(:book1_chapter3).id, last_chapter_id: chapters(:book1_chapter2).id)
    Timecop.freeze(Time.current.change(hour: 6))

    assert_equal @channel_started.current_chapter, chapters(:book1_chapter2)
  end

  test "current_chapter after delivery" do
    @channel_started.update!(next_chapter_id: chapters(:book1_chapter3).id, last_chapter_id: chapters(:book1_chapter2).id)
    Timecop.freeze(Time.current.change(hour: 10))

    assert_equal @channel_started.current_chapter, chapters(:book1_chapter3)
  end
end
