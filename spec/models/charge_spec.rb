require 'rails_helper'

RSpec.describe Charge, type: :model do
  before do
    @charge = build(:charge)
  end

  describe 'active?' do
    context 'when active' do
      let!(:charge) { build(:charge) }

      it 'should return true' do
        expect(charge.active?).to be_truthy
      end
    end

    context 'when trialing' do
      let!(:charge) { build(:charge, :trialing) }

      it 'should return true' do
        expect(charge.active?).to be_truthy
      end
    end

    context 'when past_due' do
      let!(:charge) { build(:charge, :past_due) }

      it 'should return true' do
        expect(charge.active?).to be_truthy
      end
    end

    context 'when canceled' do
      let!(:charge) { build(:charge, :canceled) }

      it 'should return false' do
        expect(charge.active?).to be_falsy
      end
    end
  end

  describe "trialing" do
    let!(:user_before_trial) { create(:user) }

    context "when user is before trial" do
      it "should be false" do
        # expect(@user).to be_valid
      end
    end
  end
end
