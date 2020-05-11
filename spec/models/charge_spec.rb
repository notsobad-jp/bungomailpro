require 'rails_helper'

RSpec.describe Charge, type: :model do
  before do
    @charge = build(:charge)
  end

  ####################################################
  # active?
  ####################################################
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

  ####################################################
  # create_subscription
  ####################################################
  describe "create_subscription" do
    subject { charge.create_subscription }

    context "when already active" do
      let(:charge) { build(:charge, :test_customer, :with_user) }

      it "should raise error" do
        expect{ subject }.to raise_error('already subscribing')
      end
    end

    context "when trial not ended yet" do
      let(:charge) { build(:charge, :test_customer, :no_subscription, user: build(:user, :stripe_customer)) }

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
      let(:charge) { build(:charge, :test_customer, :no_subscription, user: build(:user, :stripe_customer, :trial_ended)) }

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

  ####################################################
  # latest_payment
  ####################################################
  describe "latest_payment" do
    context "when paid payment exists" do
      # トライアル終了状態でsubscriptionつくってすぐに支払いを発生させる
      let(:charge) { build(:charge, :test_customer, :no_subscription, user: build(:user, :trial_ended)) }

      it "should return paid payment" do
        VCR.use_cassette('stripe/latest_payment_paid') do
          charge.create_subscription
          expect(charge.latest_payment.paid).to be_truthy
        end
      end

      it "should return non-refunded payment" do
        VCR.use_cassette('stripe/latest_payment_paid') do
          charge.create_subscription
          expect(charge.latest_payment.refunded).to be_falsey
        end
      end
    end

    context "when refunded payment exists" do
      # トライアル終了状態でsubscriptionつくってすぐに支払いを発生させる
      let(:charge) { build(:charge, :test_customer, :no_subscription, user: build(:user, :trial_ended)) }

      it "should return nil" do
        VCR.use_cassette('stripe/latest_payment_refunded') do
          charge.create_subscription
          charge.refund_latest_payment
          expect(charge.latest_payment).to be_nil
        end
      end
    end

    context "when latest payment not exists" do
      let(:charge) { build(:charge, :test_customer, :no_subscription, :with_user) }

      it "should return nil" do
        VCR.use_cassette('stripe/latest_payment_not_exists') do
          charge.create_subscription
          expect(charge.latest_payment).to be_nil
        end
      end
    end
  end

  ####################################################
  # refund_latest_payment
  ####################################################
  describe "refund_latest_payment" do
    context "when last payment exists" do
      # トライアル終了状態でsubscriptionつくってすぐに支払いを発生させる
      let(:charge) { build(:charge, :test_customer, :no_subscription, user: build(:user, :trial_ended)) }

      it "should refund payment" do
        VCR.use_cassette('stripe/refund_success') do
          charge.create_subscription
          charge.refund_latest_payment
          expect(charge.latest_payment).to be_nil
        end
      end

      it "should succeed refunding" do
        VCR.use_cassette('stripe/refund_success') do
          charge.create_subscription
          expect(charge.refund_latest_payment.status).to eq('succeeded')
        end
      end
    end

    context "when last payment not exists" do
      let(:charge) { build(:charge, :test_customer, :no_subscription, :with_user) }
      subject { charge.refund_latest_payment }

      it "should raise error" do
        VCR.use_cassette('stripe/refund_not_exists') do
          charge.create_subscription
          expect{ subject }.to raise_error 'no payment exists'
        end
      end
    end
  end

  ####################################################
  # create_or_update_customer
  ####################################################
  describe "create_or_update_customer" do
    context "when customer not exists" do
      let(:charge) { build(:charge, :no_customer, :no_subscription, user: build(:user, email: 'create_or_update_customer@bungomail.com')) }

      it "should create customer and update payment info" do
        VCR.use_cassette('stripe/create_customer') do
          token = Stripe::Token.create({ card: { number: '4242424242424242', exp_month: 1, exp_year: 2030, cvc: '123' } })
          charge.create_or_update_customer(stripeEmail: charge.user.email, stripeToken: token.id)
          expect(charge.last4).to eq("4242")
        end
      end
    end

    context "when customer already exists" do
      let(:charge) { build(:charge, user: build(:user, email: 'create_or_update_customer2@bungomail.com')) }

      it "should create customer and update payment info" do
        VCR.use_cassette('stripe/update_customer') do
          token = Stripe::Token.create({ card: { number: '4242424242424242', exp_month: 1, exp_year: 2030, cvc: '123' } })
          customer = Stripe::Customer.create({email: charge.user.email, source: token.id})
          charge.customer_id = customer.id

          token = Stripe::Token.create({ card: { number: '4242424242424242', exp_month: 5, exp_year: 2030, cvc: '123' } })
          charge.create_or_update_customer(stripeEmail: charge.user.email, stripeToken: token.id)
          expect(charge.exp_month).to eq(5)
        end
      end
    end
  end
end
