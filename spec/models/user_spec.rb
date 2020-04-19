require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = build(:user)
  end

  context "when user is valid" do
    it "has a valid factory" do
      expect(@user).to be_valid
    end
  end
end
