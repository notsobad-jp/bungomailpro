require 'rails_helper'

RSpec.describe Channel, type: :model do
  before do
    WebMock.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").to_return(body: "https://bit.ly/3q3sjgW")
  end

  describe "update_jobs_run_at" do
    let(:channel) { create(:channel, delivery_time: '10:00:00') }

    before do
      @ba = create(:book_assignment, :with_book, channel: channel)
      @ba.create_and_schedule_feeds
    end

    context "when delivery_time not changed" do
      it "should have original run_at" do
        expect(channel.delayed_jobs.minimum(:run_at)).to eq(@ba.start_date.to_time.change(hour: 10))
        expect(channel.delayed_jobs.maximum(:run_at)).to eq(@ba.end_date.to_time.change(hour: 10))
      end
    end

    context "when delivery_time changed" do
      it "should update run_at with new time" do
        channel.update(delivery_time: '15:00:00')
        expect(channel.delayed_jobs.minimum(:run_at)).to eq(@ba.start_date.to_time.change(hour: 15))
        expect(channel.delayed_jobs.maximum(:run_at)).to eq(@ba.end_date.to_time.change(hour: 15))
      end
    end
  end

  describe "nearest_assignable_date" do
    context "when no feed exists" do
      let(:channel) { create(:channel) }

      it "should return tomorrow" do
        expect(channel.nearest_assignable_date).to eq(Time.zone.tomorrow)
      end
    end

    context "when assignment last_date is not passed yet" do
      let(:channel) { create(:channel, :with_book_assignment) }

      it "should return the day after last_date" do
        expect(channel.nearest_assignable_date).to eq(Time.zone.today.next_month.end_of_month.next_day)
      end
    end
  end

  describe "recent_author_ids" do
    let(:channel) { create(:channel) }

    context "when it has book_assignments" do
      it "should return recent author ids" do
        books = create_list(:aozora_book, 10)
        books.each_with_index do |book, index|
          create(:book_assignment, channel_id: channel.id, book_id: book.id, start_date: Time.zone.today.ago(index.month), end_date: Time.zone.today.ago(index.month).since(20.days))
        end
        expect(channel.recent_author_ids).to eq([1,2,3,4,5,6])
        expect(channel.recent_author_ids(3)).to eq([1,2,3])
      end
    end

    context "when it has no book_assignment" do
      it "should return blank" do
        expect(channel.recent_author_ids).to eq([])
      end
    end
  end
end
