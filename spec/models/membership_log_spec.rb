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
end
