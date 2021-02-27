require 'rails_helper'

RSpec.describe Subscription, type: :model do
  before do
    # WebMock.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").to_return(body: "https://bit.ly/3q3sjgW")
  end

  describe "insert_google_member" do
    # context "when no google_group_key exists" do
    #   let(:subscription) { create(:subscription) }
    #
    #   it "should have original run_at" do
    #     expect(subscription.google_insert_member).to be_truthy
    #   end
    # end
    #
    # context "when no google_group_key exists" do
    #   let(:subscription) { create(:subscription, channel: create(:channel, google_group_key: 'test')) }
    #
    #   it "should have original run_at" do
    #     expect(channel.delayed_jobs.minimum(:run_at)).to eq(Time.zone.tomorrow.to_time.change(hour: 10))
    #     expect(channel.delayed_jobs.maximum(:run_at)).to eq((Time.zone.tomorrow + 29).to_time.change(hour: 10))
    #   end
    # end
  end
end
