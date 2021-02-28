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
      expect(m_log.send(:applicable?)).to be_truthy
    end

    it "should not be applicable when apply_at not passed" do
      m_log = build(:membership_log, apply_at: Time.current.since(1.hour))
      expect(m_log.send(:applicable?)).to be_falsy
    end

    it "should not be applicable when finished" do
      m_log = build(:membership_log, finished: true)
      expect(m_log.send(:applicable?)).to be_falsy
    end

    it "should not be applicable when canceled" do
      m_log = build(:membership_log, status: :canceled)
      expect(m_log.send(:applicable?)).to be_falsy
    end
  end

  describe "apply" do
    context "when not applicable" do
      let(:m_log) { create(:membership_log, apply_at: Time.current.since(1.hour)) }

      it "should return nil" do
        expect(m_log.apply).to be_nil
      end
    end

    context "when applicable" do
      let!(:official_channel) { create(:channel, id: Channel::OFFICIAL_CHANNEL_ID) }
      let!(:juvenile_channel) { create(:channel, id: Channel::JUVENILE_CHANNEL_ID) }
      let(:m_log) { create(:membership_log, plan: 'basic', status: :trialing) }

      it "should apply plan and status" do
        expect{m_log.apply}.to change(m_log.membership, :plan).from('free').to('basic').
                           and change(m_log.membership, :status).from('active').to('trialing').
                           and change(m_log, :finished).from(false).to(true)
      end
    end
  end
end
