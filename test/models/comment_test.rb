# == Schema Information
#
# Table name: comments
#
#  id         :bigint(8)        not null, primary key
#  channel_id :bigint(8)        not null
#  text       :text
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "next_chapter exists" do
    channel_started = channels(:started)
    channel_started.last_chapter = chapters(:book1_chapter1)
    channel_started.next_chapter = chapters(:book1_chapter2)

    assert_nil channel_started.add_comment
  end

  test "!next_chapter && next_channel_book" do
    channel_started = channels(:started)
    channel_started.last_chapter = chapters(:book1_chapter2)
    channel_started.next_chapter = chapters(:book1_chapter3)

    comment = channel_started.add_comment
    assert comment.text.include? '翌日からは次の作品の配信が始まります。'
  end

  test "!next_chapter && !next_channel_book" do
    channel_started = channels(:started)
    channel_started.last_chapter = chapters(:book2_chapter1)
    channel_started.next_chapter = chapters(:book2_chapter2)
    channel_started.next_channel_book.update(delivered: true)

    comment = channel_started.add_comment
    assert comment.text.include? '現在次の作品が登録されていないため'
  end
end
