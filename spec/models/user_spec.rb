require 'rails_helper'

RSpec.describe User, type: :model do
  describe "activate" do
    it "should has free & active membership after activation" do
      user = create(:user)
      user.activate!
      expect(user.reload.membership.plan).to eq('free')
    end
  end

  describe "validates gmail alias email" do
    context "on: :create" do
      it "should accept normal gmail address" do
        user = build(:user, email: "hogehoge@gmail.com")
        expect(user.valid?).to be_truthy
      end

      it "should not accept gmail alias address" do
        user = build(:user, email: "hogehoge+hoge@gmail.com")
        expect(user.valid?).to be_falsy
        expect(user.errors.full_messages).to include("Emailは不正な値です")
      end
    end

    context "on: :update" do
      it "should accept normal gmail address" do
        email = "hogehoge@gmail.com"
        User.insert({email: email, created_at: Time.current, updated_at: Time.current})
        user = User.find_by(email: email)
        user.activation_state = "hogehoge"  # 適当な変更
        expect(user.valid?).to be_truthy
      end

      it "should accept gmail alias address" do
        email = "hogehoge+hoge@gmail.com"
        User.insert({email: email, created_at: Time.current, updated_at: Time.current})
        user = User.find_by(email: email)
        user.activation_state = "hogehoge"  # 適当な変更
        expect(user.valid?).to be_truthy
      end
    end
  end

  # 退会時は全削除してEmailDigestだけ残る
  describe "cancel membership" do
    let(:user) { create(:user) }

    it "should leave EmailDigest" do
      email_digest = EmailDigest.find_by(digest: Digest::SHA256.hexdigest(user.email))
      user.destroy
      expect(User.exists?(user.id)).to be_falsy
      expect(EmailDigest.exists?(email_digest.id)).to be_truthy
    end
  end

  describe "re-registration after trial" do
    let(:email) { "hogehoge@example.com" }
    let(:trial_ended_at) { Time.zone.parse("2021-01-01") }

    it "should accept registration" do
      EmailDigest.create(digest: Digest::SHA256.hexdigest(email), trial_ended_at: trial_ended_at)
      expect(create(:user, email: email)).to be_truthy
    end

    it "should has trial_end_at" do
      EmailDigest.create(digest: Digest::SHA256.hexdigest(email), trial_ended_at: trial_ended_at)
      user = create(:user, email: email)
      user.activate!
      expect(user.membership.trial_end_at).to eq(trial_ended_at)
    end
  end
end
