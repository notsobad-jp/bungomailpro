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
