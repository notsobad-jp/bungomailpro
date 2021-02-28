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

    context "when plan and status not changed" do
      it "should not change subscription status" do
        membership.update(plan: 'basic', status: :trialing)
        expect{membership.update(stripe_customer_id: 'CUS_xxxxx')}.not_to change{Subscription.count}
      end
    end
  end

  describe "cancel_basic_plan" do
    let(:user) { create(:user, :with_basic_membership) }
  end
end
