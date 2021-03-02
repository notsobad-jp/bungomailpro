require 'rails_helper'

RSpec.describe User, type: :model do
  describe "activate" do
    it "should has free & active membership after activation" do
      user = create(:user)
      user.activate!
      expect(user.reload.membership.plan).to eq('free')
    end
  end


  # 退会時は全削除してEmailDigestを更新する
  describe "cancel membership" do
    let(:user) { create(:user) }

    it "should update deleted_at of EmailDigest" do
      email_digest = EmailDigest.find_by(digest: Digest::SHA256.hexdigest(user.email))
      user.destroy
      expect(User.exists?(user.id)).to be_falsy
      expect(email_digest.reload.deleted_at.between?(Time.current.ago(1.minute), Time.current)).to be_truthy
    end
  end


  describe "re-registration after destroy" do
    let(:email) { "hogehoge@example.com" }

    context "when canceled before renewal" do
      it "should accept registration" do
        EmailDigest.create(digest: Digest::SHA256.hexdigest(email), deleted_at: Time.zone.parse("2018-05-01"))
        expect(create(:user, email: email)).to be_truthy
      end
    end

    context "when canceled after renewal" do
      it "should deny registration" do
        EmailDigest.create(digest: Digest::SHA256.hexdigest(email), deleted_at: Time.zone.parse("2022-05-01"))
        create(:user, email: email) rescue exception = $! # $! は例外クラスのこと
        expect(exception.class).to eq(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
