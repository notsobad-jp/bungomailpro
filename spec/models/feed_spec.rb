require 'rails_helper'

RSpec.describe Feed, type: :model do
  before do
    WebMock.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").to_return(body: "https://bit.ly/3q3sjgW")
  end

  describe "send_at" do
    let(:feed) { build(:feed, delivery_date: Time.zone.today) }

    it "should return datetime with channel hour" do
      expect(feed.send_at).to eq(Time.current.change(hour: 7))
    end
  end

  describe "schedule" do
    context "when send_at already passed" do
      let(:feed) { build(:feed, delivery_date: Time.zone.yesterday) }

      it "should return without enqueueing" do
        res = feed.schedule
        expect(res).to be_nil
        expect(feed.delayed_job_id).to be_nil
      end
    end

    context "when send_at not passed yet" do
      let(:feed) { create(:feed, delivery_date: Time.zone.tomorrow) }

      before do
        feed.book_assignment.channel.update(delivery_time: '10:00:00')
      end

      it "should enqueue the job" do
        feed.schedule
        expect(feed.delayed_job_id).not_to be_nil
      end

      it "should has correct run_at on job" do
        feed.schedule
        expect(feed.delayed_job.run_at).to eq(Time.zone.tomorrow.to_time.change(hour: 10))
      end
    end
  end
end
