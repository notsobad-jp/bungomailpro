require 'rails_helper'

RSpec.describe Charge, type: :model do
  before do
    @charge = build(:charge)
  end

  describe "trialing" do
    let!(:user_before_trial) { create(:user) }

    context "when user is before trial" do
      it "should be false" do
        expect(@user).to be_valid
      end
    end
  end
end
