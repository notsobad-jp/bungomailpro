require 'rails_helper'

RSpec.describe MembershipLog, type: :model do
  it "should be valid" do
    m_log = build(:membership_log)
    expect(m_log.valid?).to be_truthy
  end
end
