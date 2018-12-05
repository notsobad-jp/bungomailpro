require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  test "publish" do
    channel = channels(:not_started)
    channel.publish

    assert_equal chapters(:book1_chapter1).id, channel.next_chapter_id
    assert_equal true, channel_books(:not_started_book_1).delivered
  end

  test "set_next_chapter when next_chapter" do
    channel = channels(:started)
    channel.update!(next_chapter_id: chapters(:book1_chapter2).id, last_chapter_id: chapters(:book1_chapter1).id)

    channel.set_next_chapter
    assert_equal chapters(:book1_chapter3).id, channel.next_chapter_id
    assert_equal chapters(:book1_chapter2).id, channel.last_chapter_id
  end

  test "set_next_chapter when !next_chapter && next_book" do
    channel = channels(:started)
    channel.update!(next_chapter_id: chapters(:book1_chapter3).id, last_chapter_id: chapters(:book1_chapter2).id)

    channel.set_next_chapter
    assert_equal chapters(:book2_chapter1).id, channel.next_chapter_id
    assert_equal chapters(:book1_chapter3).id, channel.last_chapter_id
  end

  test "set_next_chapter when !next_chapter && !next_book" do
    channel = channels(:started)
    channel.update!(next_chapter_id: chapters(:book2_chapter2).id, last_chapter_id: chapters(:book2_chapter1).id)
    channel_book = channel_books(:started_book_2)
    channel_book.update!(delivered: true)

    channel.set_next_chapter
    assert_nil channel.next_chapter_id
    assert_equal chapters(:book2_chapter2).id, channel.last_chapter_id
  end


  test "current_chapter before delivery" do
  end

  test "current_chapter after delivery" do
  end
end
