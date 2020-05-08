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


  describe "create_recipient", vcr: true do
    let(:user) { create(:user, :not_activated) }
    it "should create new recipient" do
      expect(user.create_recipient).to be_truthy
    end
  end

  describe "add_to_list", vcr: true do
    let(:user) { create(:user, :activated) }

    context "when user not added yet" do
      it "should add recipient to list" do
        recipient = user.create_recipient
        user.update(sendgrid_id: recipient.dig("persisted_recipients", 0))
        expect(user.add_to_list).to be_truthy
      end
    end

    context "when user already added" do
    end
  end

  describe "remove_from_list", vcr: true do
    let(:user) { create(:user, :activated) }
    
    context "when user already added" do
      it "should remove recipient from list" do
        recipient = user.create_recipient
        user.update(sendgrid_id: recipient.dig("persisted_recipients", 0))
        user.add_to_list
        expect(user.remove_from_list).to be_truthy
      end
    end

    context "when user not added yet" do
    end
  end

  # describe "start_trial_now" do
  #   let!(:user) { create(:user) } # before_trial
  #   subject { user.start_trial_now }
  #
  #   it "should add user to the list" do
  #     expect(user.list_subscribed).to be_truthy
  #   end
  # end
end
