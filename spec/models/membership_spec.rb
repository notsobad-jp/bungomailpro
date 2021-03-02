require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe "start_trialing" do
    let!(:membership) { create(:membership) } # callbackでsubscription作成するので、このタイミングで実行しておく

    context "when trial started" do
      it "should subscribe official channel" do
        expect{membership.update(plan: 'basic', trialing: true)}.to change{Subscription.count}.by(1)
        expect(membership.user.subscriptions.find_by(channel_id: Channel::OFFICIAL_CHANNEL_ID)).to be_truthy
      end
    end

    # plan, statusが更新されてない場合はcallbackを実行しない
    context "when plan and status not changed" do
      it "should not change subscription status" do
        membership.update(plan: 'basic', trialing: true)
        expect{membership.update(stripe_customer_id: 'CUS_xxxxx')}.not_to change{Subscription.count}
      end
    end
  end

  describe "cancel_basic_plan" do
    let!(:user) { create(:user, :with_basic_membership, :with_juvenile_sub, :with_official_sub) }

    context "when user has a custom channel and subscribing public channel" do
      before do
        custom_channel = create(:channel, user: user)
        user.subscriptions.create(channel_id: custom_channel.id)
        public_channel = create(:channel)
        user.subscriptions.create(channel_id: public_channel.id)
      end

      subject { user.membership.update(plan: 'free', trialing: false)  }

      it "should destroy all channels & subscriptions except for juvenile" do
        expect{subject}.to change{user.subscriptions.count}.from(4).to(1).
                       and change{user.channels.count}.from(1).to(0)
        expect(user.reload.subscriptions.pluck(:channel_id)).to eq([Channel::JUVENILE_CHANNEL_ID])
      end
    end
  end

  describe "cancel_free_plan" do
    let!(:user) { create(:user, :with_basic_membership, :with_juvenile_sub, :with_official_sub) }

    context "when user has a custom channel and subscribing public channel" do
      before do
        custom_channel = create(:channel, user: user)
        user.subscriptions.create(channel_id: custom_channel.id)
        public_channel = create(:channel)
        user.subscriptions.create(channel_id: public_channel.id)
      end

      subject { user.membership.update(plan: nil, trialing: false) }

      it "should destroy all channels & subscriptions" do
        expect{subject}.to change{User.count}.by(-1).
                       and change{Membership.count}.by(-1).
                       and change{Subscription.count}.by(-4)
        expect(User.exists?(user.id)).to be_falsy
      end
    end
  end
end
