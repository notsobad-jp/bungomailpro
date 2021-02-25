require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    context "when not logged in" do
      it "should return 200" do
        get signup_path
        expect(response).to be_successful
      end
    end

    context "when logged in" do
      it "should be redirected to mypage" do
        user = create(:user)
        login(user)
        get signup_path
        expect(response).to redirect_to(mypage_path)
      end
    end
  end

  describe "GET /login" do
    context "when not logged in" do
      it "should return 200" do
        get login_path
        expect(response).to be_successful
      end
    end

    context "when logged in" do
      it "should be redirected to mypage" do
        user = create(:user)
        login(user)
        get login_path
        expect(response).to redirect_to(mypage_path)
      end
    end
  end
end
