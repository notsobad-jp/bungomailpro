require 'rails_helper'

RSpec.describe BookAssignment, type: :model do
  before do
    # WebMock.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").to_return(body: "https://bit.ly/3q3sjgW")
  end

  describe "create_chapters" do
    let(:book_assignment) { create(:book_assignment, :with_book) }

    describe "with different count" do
      context "when it has 30 count" do
        it "should have 30 chapters" do
          VCR.use_cassette("bitly") do
            book_assignment.create_chapters
            expect(book_assignment.chapters.length).to eq(30)
          end
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

  describe "delivery_period_should_not_overlap" do
    let(:book_assignment) { create(:book_assignment, :with_book) }

    context "with overlapping period" do
      # 対象期間が既存レコードに先行するとき
      context "when new period proceeds the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today - 10)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:start_date]).to include("配信期間が重複しています")
        end
      end

      # 対象期間が既存レコードに後続するとき
      context "when new period succeeds the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today + 10)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:start_date]).to include("配信期間が重複しています")
        end
      end

      # 対象期間が既存レコードを包含するとき
      context "when new period includes the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today, count: 50)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:start_date]).to include("配信期間が重複しています")
        end
      end

      # 対象期間が既存レコードに包含されるとき
      context "when new period is included by the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today + 2, count: 10)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:start_date]).to include("配信期間が重複しています")
        end
      end
    end

    # 期間重複してても他のチャネルならOK
    context "when other channel has overlapping record" do
      it "should be valid" do
        ba = build(:book_assignment, book: book_assignment.book, start_date: Time.zone.today)
        expect(ba.valid?).to be_truthy
      end
    end
  end
end
