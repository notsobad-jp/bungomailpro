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

require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)
  end

  ########################################################################
  # add_book
  ########################################################################
  test "add_book" do
    channel = channels(:channel1)
    assert_equal 2, channel.books.count
    assert_equal 2, channel.max_index
    channel.add_book(books(:book3))
    assert_equal 3, channel.books.count
    assert_equal 3, channel.max_index
  end


  ########################################################################
  # set default
  ########################################################################
  test "set default channel" do
    channel0 = channels(:channel0)
    channel1 = channels(:channel1)
    assert channel0.default?
    assert_equal 1, @user1.channels.where(default: true).size

    channel1.update(default: true)
    assert channel1.default?
    assert_equal 1, @user1.channels.where(default: true).size
  end


  ########################################################################
  # latest_index
  ########################################################################
  test "latest_index_with_no_subscribers" do
    channel = channels(:channel3)
    assert_equal 0, channel.latest_index
  end

  test "latest_index_with_owner_only" do
    channel = channels(:channel4)
    assert_equal 1, channel.latest_index
  end

  test "latest_index_with_multiple_subscribers" do
    channel = channels(:channel1)
    assert_equal 2, channel.latest_index
  end
end
