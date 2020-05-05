require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user_not_activated)           { create(:user, :not_activated) }
  let!(:user)                         { create(:user) } # before_trial
  let!(:user_trialing_with_charge)    { create(:user_trialing_with_charge) }
  let!(:user_trialing_without_charge) { create(:user_trialing_without_charge) }
  let!(:user_subscribing_with_charge) { create(:user_subscribing_with_charge) }
  let!(:user_paused_with_charge)      { create(:user_paused_with_charge) }
  let!(:user_paused_without_charge)   { create(:user_paused_without_charge) }

  describe "trialing" do
    subject { User.trialing }

    it { is_expected.not_to include user_not_activated }
    it { is_expected.not_to include user }
    it { is_expected.to     include user_trialing_with_charge }
    it { is_expected.to     include user_trialing_without_charge }
    it { is_expected.not_to include user_subscribing_with_charge }
    it { is_expected.not_to include user_paused_with_charge }
    it { is_expected.not_to include user_paused_without_charge }
  end

  describe "charging" do
    subject { User.charging }

    it { is_expected.not_to include user_not_activated }
    it { is_expected.not_to include user }
    it { is_expected.to     include user_trialing_with_charge }
    it { is_expected.not_to include user_trialing_without_charge }
    it { is_expected.to     include user_subscribing_with_charge }
    it { is_expected.to     include user_paused_with_charge }
    it { is_expected.not_to include user_paused_without_charge }
  end

  describe "not_charging" do
    subject { User.not_charging }

    it { is_expected.to     include user_not_activated }
    it { is_expected.to     include user }
    it { is_expected.not_to include user_trialing_with_charge }
    it { is_expected.to     include user_trialing_without_charge }
    it { is_expected.not_to include user_subscribing_with_charge }
    it { is_expected.not_to include user_paused_with_charge }
    it { is_expected.to     include user_paused_without_charge }
  end

  describe "valid_and_paused" do
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

  describe "invalid_and_subscribing" do
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
