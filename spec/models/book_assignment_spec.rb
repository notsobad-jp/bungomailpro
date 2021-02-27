require 'rails_helper'

RSpec.describe BookAssignment, type: :model do
  describe "create_chapters" do
    let(:book_assignment) { create(:book_assignment, :with_book) }

    describe "with different count" do
      context "when it has 30 count" do
        it "should have 30 chapters" do
          book_assignment.create_chapters
          expect(book_assignment.chapters.length).to eq(30)
        end
      end

      context "when it has 10 count" do
        it "should have 10 chapters" do
          book_assignment.update(count: 10)
          book_assignment.create_chapters
          expect(book_assignment.chapters.length).to eq(10)
        end
      end
    end

    describe "with different start_date" do
      context "when it start on yesterday" do
        it "should have correct delivery_date" do
          book_assignment.update(start_date: Time.zone.yesterday)
          book_assignment.create_chapters
          expect(book_assignment.chapters.minimum(:delivery_date)).to eq(Time.zone.yesterday)
          expect(book_assignment.chapters.maximum(:delivery_date)).to eq(Time.zone.yesterday + 29)
        end
      end
    end
  end
end
