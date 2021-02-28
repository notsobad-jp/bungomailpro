require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe "start_trialing" do
    let(:membership) { create(:membership) }

    it "should subscribe official channel" do
      # membership.
      expect(user.membership.plan).to eq('basic')
      expect(user.membership.status).to eq(:trialing)
    end
  end
end
