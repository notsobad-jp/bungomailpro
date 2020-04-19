require 'rails_helper'

RSpec.describe BookAssignment, type: :model do
  before do
    @ba_with_aozora = build(:ba_with_aozora)
    @ba_with_guten = build(:ba_with_guten)
  end

  context "when it has books" do
    it "should be valid with aozora_book" do
      expect(@ba_with_aozora).to be_valid
    end

    it "should be valid with guten_book" do
      expect(@ba_with_guten).to be_valid
    end
  end
end
