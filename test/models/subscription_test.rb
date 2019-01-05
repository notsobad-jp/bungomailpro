# == Schema Information
#
# Table name: subscriptions
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)        not null
#  channel_id         :bigint(8)        not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  default            :boolean          default(FALSE), not null
#  current_book_id    :bigint(8)
#  next_chapter_index :integer
#  delivery_hour      :integer          default(8), not null
#  next_delivery_date :date
#

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)
    @user2 = users(:user2)
  end

  test "channel owned" do
    sub = subscriptions(:user1_empty)

    assert sub.channel_owned?
  end

  test "channel not owned" do
    channel1 = channels(:empty)
    sub = @user2.subscriptions.create(channel_id: channel1.id)

    assert !sub.channel_owned?
  end

  test "owned and no default exists" do
    channel = channels(:user2)
    sub = @user2.subscriptions.create(channel_id: channel.id)

    assert sub.default
  end

  test "owned and default exists" do
    channel1 = channels(:user2)
    sub1 = @user2.subscriptions.create(channel_id: channel1.id)

    channel2 = channels(:user2_2)
    sub2 = @user2.subscriptions.create(channel_id: channel2.id)

    assert sub1.default
    assert !sub2.default
  end

  test "not owned and no default exists" do
    channel = channels(:empty)
    sub = @user2.subscriptions.create(channel_id: channel.id)

    assert !sub.default
  end

  test "not owned and default exists" do
    channel1 = channels(:user2)
    sub1 = @user2.subscriptions.create(channel_id: channel1.id)

    channel2 = channels(:empty)
    sub2 = @user2.subscriptions.create(channel_id: channel2.id)

    assert sub1.default
    assert !sub2.default
  end
end
