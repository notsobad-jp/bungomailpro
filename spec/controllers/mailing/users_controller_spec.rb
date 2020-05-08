require 'rails_helper'

RSpec.describe Mailing::UsersController, type: :controller do
  before do
    @user = create(:user)
  end

  ####################################################
  # create
  ####################################################
  describe "#create" do
    before { @new_user = build(:user) }
    subject { post :create, params: { user: { email: @new_user.email } }, session: {} }

    context "as an existing user" do
      it "sends login email" do
        post :create, params: { locale: :en, user: { email: @user.email } }, session: {}
        expect(flash[:info]).to include("登録済みのアドレスに")
      end
    end

    context "as a new :en user" do
      it "responds successfully" do
        subject
        expect(flash[:success]).to include("認証用メールを送信しました")
      end

      it "creates new user" do
        expect{ subject }.to change(User, :count).by(1)
      end
    end
  end


  ####################################################
  # show
  ####################################################
  describe "#show" do
    subject { get :show, params: { id: @user.id, locale: :en }, session: {} }

    context "as a guest" do
      it "returns a 302 response" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as an other user" do
      before { login_user(create(:user)) }

      it "returns a 302 response" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as an owner" do
      before { login_user(@user) }

      it "responds successfully" do
        subject
        expect(response).to be_successful
      end
    end
  end


  ####################################################
  # edit
  ####################################################
  describe "#edit" do
    subject { get :edit, params: { id: @user.id, locale: :en }, session: {} }

    context "as a guest" do
      it "returns a 302 response" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as an other user" do
      before { login_user(create(:user)) }

      it "returns a 302 response" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as an owner" do
      before { login_user(@user) }

      it "responds successfully" do
        subject
        expect(response).to be_successful
      end
    end
  end


  ####################################################
  # update
  ####################################################
  # describe "#update" do
  #   subject { patch :update, params: { id: @user.id, locale: :en, user: { timezone: 'Tokyo' } }, session: {} }
  #
  #   context "as a guest" do
  #     it "returns a 302 response" do
  #       subject
  #       expect(response).to redirect_to login_url
  #       expect(response).to have_http_status "302"
  #     end
  #   end
  #
  #   context "as an other user" do
  #     before { login_user(create(:user)) }
  #
  #     it "returns a 302 response" do
  #       subject
  #       expect(response).to redirect_to login_url
  #       expect(response).to have_http_status "302"
  #     end
  #   end
  #
  #   context "as an owner" do
  #     before { login_user(@user) }
  #
  #     it "updates attributes with valid params" do
  #       subject
  #       expect(@user.reload.timezone).to eq 'Tokyo'
  #     end
  #
  #     it "returns error with invalid params" do
  #       patch :update, params: { id: @user.id, locale: :en, user: { timezone: "" } }, session: {}
  #       expect(flash[:error]).to include("failed")
  #     end
  #   end
  # end
end
