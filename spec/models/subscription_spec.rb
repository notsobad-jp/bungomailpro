require 'rails_helper'

RSpec.describe Subscription, type: :model do
  # Insert Member to Google Group
  describe "insert_google_member" do
    context "when no google_group_key exists" do
      let(:subscription) { create(:subscription) }

      it "should raise exception" do
        expect(subscription.google_insert_member).to be_nil
      end
    end

    context "when google_group_key exists" do
      context "with valid & non-existing email" do
        let(:subscription) { create(:subscription, channel: create(:channel, :with_google_group)) }

        it "should succeed" do
          VCR.use_cassette 'model/subscription/google_insert_member/valid' do
            expect(subscription.google_insert_member).to be_truthy
          end
        end
      end

      context "with existing email" do
        let(:subscription) { create(:subscription, user: create(:user, email: 'test5@example.com'), channel: create(:channel, :with_google_group)) }

        it "should raise duplicate exception" do
          VCR.use_cassette 'model/subscription/google_insert_member/duplicated' do
            subscription.google_insert_member rescue exception = $! # $! は例外クラスのこと
            expect(exception.status_code).to eq(409)
            expect(exception.message).to include("duplicate")
          end
        end
      end

      context "with invalid email" do
        let(:subscription) { create(:subscription, user: create(:user, email: 'hoge@gmail.com'), channel: create(:channel, :with_google_group)) }

        it "should raise notFound exception" do
          VCR.use_cassette 'model/subscription/google_insert_member/invalid' do
            subscription.google_insert_member rescue exception = $! # $! は例外クラスのこと
            expect(exception.status_code).to eq(404)
            expect(exception.message).to include("notFound")
          end
        end
      end

      context "with aliased email" do
        let(:subscription) { create(:subscription, user: create(:user, email: 'test5+alias@gmail.com'), channel: create(:channel, :with_google_group)) }

        it "should raise notFound exception" do
          VCR.use_cassette 'model/subscription/google_insert_member/aliased' do
            subscription.google_insert_member rescue exception = $! # $! は例外クラスのこと
            expect(exception.status_code).to eq(404)
            expect(exception.message).to include("notFound")
          end
        end
      end
    end
  end
end
