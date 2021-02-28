require 'rails_helper'

RSpec.describe Membership, type: :model do
  let!(:official_channel) { create(:channel, id: Channel::OFFICIAL_CHANNEL_ID) }
  let!(:juvenile_channel) { create(:channel, id: Channel::JUVENILE_CHANNEL_ID) }

  describe "start_trialing" do
    let(:membership) { create(:membership) }

    context "when trial started" do
      it "should subscribe official channel" do
        expect{membership.update(plan: 'basic', status: :trialing)}.to change{Subscription.count}.by(1)
        expect(membership.user.subscriptions.find_by(channel_id: Channel::OFFICIAL_CHANNEL_ID)).to be_truthy
      end
    end

    # plan, statusが更新されてない場合はcallbackを実行しない
    context "when plan and status not changed" do
      it "should not change subscription status" do
        membership.update(plan: 'basic', status: :trialing)
        expect{membership.update(stripe_customer_id: 'CUS_xxxxx')}.not_to change{Subscription.count}
      end
    end
  end

  describe "cancel_basic_plan" do
    let(:user) { create(:user, :with_basic_membership) }

    context "when user has a custom channel and subscribing public channel" do
      before do
        @juv_sub = user.subscriptions.create(channel_id: Channel::JUVENILE_CHANNEL_ID)
        custom_channel = create(:channel, user: user)
        user.subscriptions.create(channel_id: custom_channel.id)
        public_channel = create(:channel)
        user.subscriptions.create(channel_id: public_channel.id)
      end

      subject { user.membership.update(plan: 'free', status: :active)  }

      it "should destroy all channels & subscriptions except for juvenile" do
        expect{subject}.to change{user.subscriptions.count}.from(4).to(1).
                       and change{user.channels.count}.from(1).to(0)
        expect(user.reload.subscriptions).to eq([@juv_sub])
      end
    end
  end
end
