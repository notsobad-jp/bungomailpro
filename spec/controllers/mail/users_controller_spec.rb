require 'rails_helper'

RSpec.describe Mail::UsersController, type: :controller do
  before do
    @user = create(:user)
  end

  ####################################################
  # create
  ####################################################
  describe "#create" do
    subject { post :create, params: { locale: :en, user: { email: @user.email } }, session: {} }

    context "as an existing user" do
      it "sends login email" do
        subject
        expect(flash[:info]).to include("already registered")
      end
    end

    context "as a new :en user" do
      xit "create user with default channel" do
        email = build(:user).email
        subject
        expect(flash[:success]).to include("Account registered")

        user = User.find_by(email: email)
        expect(user.channels.length).to eq 1
        expect(user.channels.first.default).to eq true
      end

      xit "create user with :en params" do
        email = build(:user).email
        subject
        expect(flash[:success]).to include("Account registered")

        user = User.find_by(email: email)
        expect(user.timezone).to eq 'UTC'
        expect(user.locale).to eq 'en'
      end
    end

    context "as a new :ja user" do
      xit "create user with :ja params" do
        email = build(:user).email
        post :create, params: { locale: :ja, user: { email: email } }, session: {}
        expect(flash[:success]).to include("Account registered")

        user = User.find_by(email: email)
        expect(user.timezone).to eq 'Tokyo'
        expect(user.locale).to eq 'ja'
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
  describe "#update" do
    subject { patch :update, params: { id: @user.id, locale: :en, user: { timezone: 'Tokyo' } }, session: {} }

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

      it "updates attributes with valid params" do
        subject
        expect(@user.reload.timezone).to eq 'Tokyo'
      end

      it "returns error with invalid params" do
        patch :update, params: { id: @user.id, locale: :en, user: { timezone: "" } }, session: {}
        expect(flash[:error]).to include("failed")
      end
    end
  end
end
