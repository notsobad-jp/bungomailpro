require 'rails_helper'

RSpec.describe Channel, type: :model do
  before do
    @channel = build(:channel)
    @ba_with_aozora = build(:ba_with_aozora)
    @ba_with_guten = build(:ba_with_guten)
  end

  context "when it has book_assignments" do
    it "should be valid with aozora_book" do
      @channel.book_assignments << @ba_with_aozora
      expect(@channel).to be_valid
      expect(@channel.book_assignments.length).to eq 1
    end

    it "should take all books" do
      @channel.book_assignments << @ba_with_aozora
      @channel.book_assignments << @ba_with_guten
      expect(@channel.save).to be_truthy

      byebug
    end
  end
end
