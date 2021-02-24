require 'rails_helper'

RSpec.describe User, type: :model do
  it "should has free & active membership after creation" do
    user = create(:user)
    expect(user.membership.plan).to eq('free')
    expect(user.membership.status).to eq('active')
  end
end
