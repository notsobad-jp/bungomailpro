require 'rails_helper'

RSpec.describe Channel, type: :model do
  before do
    WebMock.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").to_return(body: "https://bit.ly/3q3sjgW")
  end

  describe "update_jobs_run_at" do
    let(:channel) { create(:channel, delivery_time: '10:00:00') }

    before do
      ba = create(:book_assignment, :with_book, channel: channel)
      ba.create_feeds
      ba.feeds.map(&:schedule)
    end

    context "when delivery_time not changed" do
      it "should have original run_at" do
        expect(channel.delayed_jobs.minimum(:run_at)).to eq(Time.zone.tomorrow.to_time.change(hour: 10))
        expect(channel.delayed_jobs.maximum(:run_at)).to eq((Time.zone.tomorrow + 29).to_time.change(hour: 10))
      end
    end

    context "when delivery_time changed" do
      it "should update run_at with new time" do
        channel.update(delivery_time: '15:00:00')
        expect(channel.delayed_jobs.minimum(:run_at)).to eq(Time.zone.tomorrow.to_time.change(hour: 15))
        expect(channel.delayed_jobs.maximum(:run_at)).to eq((Time.zone.tomorrow + 29).to_time.change(hour: 15))
      end
    end
  end
end
