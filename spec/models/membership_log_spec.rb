require 'rails_helper'

RSpec.describe MembershipLog, type: :model do
  describe "scope: applicable" do
    it "should include right records" do
      log = create(:membership_log, apply_at: Time.current.yesterday)
      create(:membership_log, apply_at: Time.current.tomorrow) # 未来日付なので対象外
      create(:membership_log, apply_at: Time.current.yesterday, finished: true) # 反映済みなので対象外
      create(:membership_log, apply_at: Time.current.yesterday, canceled: true) # キャンセル済みなので対象外

      expect(MembershipLog.applicable.length).to eq(1)
      expect(MembershipLog.applicable.include?(log)).to be_truthy
    end
  end

  describe "scope: scheduled" do
    it "should include right records" do
      log = create(:membership_log, apply_at: Time.current.tomorrow)
      create(:membership_log, apply_at: Time.current.yesterday) # 過去日付なので対象外
      create(:membership_log, apply_at: Time.current.tomorrow, finished: true) # 反映済みなので対象外
      create(:membership_log, apply_at: Time.current.tomorrow, canceled: true) # キャンセル済みなので対象外

      expect(MembershipLog.scheduled.length).to eq(1)
      expect(MembershipLog.scheduled.include?(log)).to be_truthy
    end
  end

  describe "applicable?" do
    it "should be applicable with valid record" do
      m_log = build(:membership_log)
      expect(m_log.applicable?).to be_truthy
    end

    it "should not be applicable when apply_at not passed" do
      m_log = build(:membership_log, apply_at: Time.current.since(1.hour))
      expect(m_log.applicable?).to be_falsy
    end

    it "should not be applicable when finished" do
      m_log = build(:membership_log, finished: true)
      expect(m_log.applicable?).to be_falsy
    end

    it "should not be applicable when canceled" do
      m_log = build(:membership_log, status: :canceled)
      expect(m_log.applicable?).to be_falsy
    end
  end

  describe "apply" do
    # free -> トライアル開始
    context "free:active -> basic:trialing" do
      let(:user) { create(:user) }
      let(:m_log) { create(:membership_log, membership: user.membership, plan: 'basic', status: :trialing) }

      it "should update membership status" do
        byebug
        m_log.apply
        expect(user.membership.plan).to eq('basic')
        expect(user.membership.status).to eq(:trialing)
      end
    end

    # free -> 解約
    context "free:active -> free:canceled" do
    end

    # free -> basicプラン開始（以前にトライアル終了してるパターン）
    context "free:active -> basic:active" do
    end

    # trialing -> basic（トライアル中に契約）
    context "basic:trialing -> basic:active" do
    end

    # trialing -> free（契約せずにトライアル終了）
    context "basic:trialing -> free:active" do
    end

    # trialing -> 解約
    context "basic:trialing -> free:canceled" do
    end

    # basic -> free（プラン解約）
    context "basic:active -> free:active" do
    end

    # basic -> 解約
    context "basic:active -> free:canceled" do
    end
  end
end
