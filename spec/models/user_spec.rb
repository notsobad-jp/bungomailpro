require 'rails_helper'

RSpec.describe User, type: :model do
  describe "scope" do
    let!(:user_not_activated)           { create(:user, :not_activated) }
    let!(:user)                         { create(:user) } # before_trial
    let!(:user_trialing_with_charge)    { create(:user_trialing_with_charge) }
    let!(:user_trialing_without_charge) { create(:user_trialing_without_charge) }
    let!(:user_subscribing_with_charge) { create(:user_subscribing_with_charge) }
    let!(:user_paused_with_charge)      { create(:user_paused_with_charge) }
    let!(:user_paused_without_charge)   { create(:user_paused_without_charge) }

    context "trialing" do
      subject { User.trialing }

      it { is_expected.not_to include user_not_activated }
      it { is_expected.not_to include user }
      it { is_expected.to     include user_trialing_with_charge }
      it { is_expected.to     include user_trialing_without_charge }
      it { is_expected.not_to include user_subscribing_with_charge }
      it { is_expected.not_to include user_paused_with_charge }
      it { is_expected.not_to include user_paused_without_charge }
    end

    context "charging" do
      subject { User.charging }

      it { is_expected.not_to include user_not_activated }
      it { is_expected.not_to include user }
      it { is_expected.to     include user_trialing_with_charge }
      it { is_expected.not_to include user_trialing_without_charge }
      it { is_expected.to     include user_subscribing_with_charge }
      it { is_expected.to     include user_paused_with_charge }
      it { is_expected.not_to include user_paused_without_charge }
    end

    context "not_charging" do
      subject { User.not_charging }

      it { is_expected.to     include user_not_activated }
      it { is_expected.to     include user }
      it { is_expected.not_to include user_trialing_with_charge }
      it { is_expected.to     include user_trialing_without_charge }
      it { is_expected.not_to include user_subscribing_with_charge }
      it { is_expected.not_to include user_paused_with_charge }
      it { is_expected.to     include user_paused_without_charge }
    end

    context "valid_and_paused" do
      let!(:user_start_trialing_without_charge) { create(:user_trialing_without_charge, list_subscribed: false) }
      subject { User.valid_and_paused }

      it { is_expected.not_to include user_not_activated }
      it { is_expected.not_to include user }
      it { is_expected.not_to include user_trialing_with_charge }
      it { is_expected.not_to include user_trialing_without_charge }
      it { is_expected.not_to include user_subscribing_with_charge }
      it { is_expected.to     include user_paused_with_charge }
      it { is_expected.not_to include user_paused_without_charge }

      # トライアル期間が開始してまだlist_subscribed=falseのままな状態
      it { is_expected.to     include user_start_trialing_without_charge }
    end

    context "invalid_and_subscribing" do
      let!(:user_finished_trialing_without_charge) { create(:user_trialing_without_charge, :trial_ended) }
      subject { User.invalid_and_subscribing }

      it { is_expected.not_to include user_not_activated }
      it { is_expected.not_to include user }
      it { is_expected.not_to include user_trialing_with_charge }
      it { is_expected.not_to include user_trialing_without_charge }
      it { is_expected.not_to include user_subscribing_with_charge }
      it { is_expected.not_to include user_paused_with_charge }
      it { is_expected.not_to include user_paused_without_charge }

      # 非課金のままトライアルを終了してまだlist_subscribed=trueのままな状態
      it { is_expected.to     include user_finished_trialing_without_charge }
    end
  end


  describe "create_recipient", :vcr do
    let(:user) { build(:user, email: 'sendgrid-test@bungomail.com') }

    it "should create new recipient" do
      VCR.use_cassette('sendgrid/create_recipient') do
        expect(user.create_recipient).to be_truthy
      end
    end
  end

  describe "add_to_list", :vcr do
    let(:user) { build(:user, :sendgrid_recipient) }

    it "should add user to list" do
      VCR.use_cassette('sendgrid/add_to_list') do
        expect(user.add_to_list).to be_nil
      end
    end
  end

  describe "remove_from_list", :vcr do
    let(:user) { build(:user, :sendgrid_recipient) }

    it "should remove user from list" do
      VCR.use_cassette('sendgrid/remove_from_list') do
        expect(user.remove_from_list).to be_nil
      end
    end
  end

  describe "start_trial_now", :vcr do
    let(:user) { create(:user, :sendgrid_recipient) }
    subject { user.start_trial_now }

    it "should add user to the list" do
      VCR.use_cassette('sendgrid/add_to_list') do
        expect{ subject }.to change{ user.list_subscribed }.from(false).to(true)
      end
    end

    it "should set trial_end to eom" do
      VCR.use_cassette('sendgrid/add_to_list') do
        expect{ subject }.to change{ user.trial_end_at }.to(Time.current.end_of_month)
      end
    end
  end

  describe "pause_subscription", :vcr do
    let(:user) { create(:user, :sendgrid_recipient, list_subscribed: true) }
    subject { user.pause_subscription }

    it "should remove user from list" do
      VCR.use_cassette('sendgrid/remove_from_list') do
        expect{ subject }.to change{ user.list_subscribed }.from(true).to(false)
      end
    end

    it "should create new skip history" do
      VCR.use_cassette('sendgrid/remove_from_list') do
        expect{ subject }.to change{ SkipHistory.count }.by(1)
      end
    end
  end
end
