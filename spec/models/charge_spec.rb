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

  describe "create_subscription" do
    subject { charge.create_subscription }

    context "when already active" do
      let(:charge) { build(:charge, :with_user) }

      it "should raise error" do
        expect{ subject }.to raise_error('already subscribing')
      end
    end

    context "when trial not ended yet" do
      let(:charge) { build(:charge, :no_subscription, user: build(:user, :stripe_customer)) }

      it "should create trialing subscription" do
        VCR.use_cassette('stripe/create_subscription_with_trial') do
          expect{ subject }.to change{ charge.status }.from(nil).to('trialing')
        end
      end

      it "should set trial_end at user.trial_end" do
        VCR.use_cassette('stripe/create_subscription_with_trial') do
          expect{ subject }.to change{ charge.trial_end }.from(nil).to(charge.user.trial_end_at)
        end
      end
    end

    context "when trial already ended" do
      let(:charge) { build(:charge, :no_subscription, user: build(:user, :stripe_customer, :trial_ended)) }

      it "should create active subscription" do
        VCR.use_cassette('stripe/create_subscription_without_trial') do
          expect{ subject }.to change{ charge.status }.from(nil).to('active')
        end
      end

      it "should set trial_end at nil" do
        VCR.use_cassette('stripe/create_subscription_without_trial') do
          expect(subject.trial_end).to eq(nil)
        end
      end
    end
  end

  describe "latest_payment_intent" do
    context "when succeeded payment exists" do
      let(:charge) { build(:charge) }

      it "should return succeeded intent" do
        VCR.use_cassette('stripe/latest_payment_intent_succeeded') do
          expect(charge.latest_payment_intent).to be_truthy
        end
      end
    end

    context "when refunded payment exists" do
      let(:charge) { build(:charge) }

      it "should return refunded intent" do
        VCR.use_cassette('stripe/latest_payment_intent_refunded') do
          expect(charge.latest_payment_intent).to be_truthy
        end
      end
    end

    context "when latest payment not exists" do
      around do |e|
        travel_to(Time.current.next_month){ e.run }
      end
      let(:charge) { build(:charge) }

      it "should return latest intent" do
        VCR.use_cassette('stripe/latest_payment_intent_not_exists') do
          expect(charge.latest_payment_intent).to be_nil
        end
      end
    end
  end

  # describe "refund_latest_payment" do
  #   subject { charge.refund_latest_payment }
  #
  #   context "when last payment exists" do
  #     let(:charge) { build(:charge) }
  #
  #     it "should refund payment" do
  #       VCR.use_cassette('stripe/refund_success') do
  #         expect(subject).to be_truthy
  #       end
  #     end
  #   end
  # end
end
