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

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)
    @user2 = users(:user2)
  end


  test "create when default exists" do
    channel1 = channels(:empty)
    sub1 = @user2.subscriptions.create(channel_id: channel1.id)

    channel2 = channels(:started)
    sub2 = @user2.subscriptions.create(channel_id: channel2.id)

    assert_equal false, sub2.default
  end

  test "create when no default exists" do
    channel = channels(:empty)
    sub = @user2.subscriptions.create(channel_id: channel.id)

    assert_equal true, sub.default
  end

  test "destroy when default exists" do
    default = @user1.default_channel
    @user1.subscriptions.find_by(default: false).destroy!

    assert_equal 2, @user1.subscriptions.count
    assert_equal default, @user1.subscriptions.find_by(default: true).channel
  end

  test "destroy when no channel and no default exists" do
    channel1 = channels(:empty)
    sub1 = @user2.subscriptions.create(channel_id: channel1.id)
    sub1.destroy!

    assert_equal 0, @user2.subscriptions.count
    assert_equal nil, @user2.default_channel
  end

  test "destroy when channel exists but no default exists" do
    @user1.subscriptions.find_by(default: true).destroy!

    assert_equal 2, @user1.subscriptions.count
    assert_equal true, @user1.subscriptions.find_by(default: true)
  end
end
