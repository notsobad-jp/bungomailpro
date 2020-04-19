require 'rails_helper'

RSpec.describe Subscription, type: :model do
  before do
    @subscription = build(:subscription)
  end

  context "when it is valid" do
    it "should be valid with user and channel" do
      expect(@subscription).to be_valid
      expect(@subscription.user).to be_truthy
      expect(@subscription.channel).to be_truthy
    end
  end
end
