require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe "send_at" do
    let(:chapter) { build(:chapter, delivery_date: Time.zone.today) }

    it "should return datetime with channel hour" do
      expect(chapter.send_at).to eq(Time.current.change(hour: 7))
    end
  end

  describe "schedule" do
    context "when send_at already passed" do
      let(:chapter) { build(:chapter, delivery_date: Time.zone.yesterday) }

      it "should return without enqueueing" do
        res = chapter.schedule
        expect(res).to be_nil
        expect(chapter.delayed_job_id).to be_nil
      end
    end

    context "when send_at not passed yet" do
      let(:chapter) { create(:chapter, delivery_date: Time.zone.tomorrow) }

      it "should enqueue the job" do
        chapter.schedule
        expect(chapter.delayed_job_id).not_to be_nil
      end
    end
  end
end
