require 'rails_helper'

RSpec.describe Mail::UsersController, type: :controller do
  before do
    @user = create(:user)
  end

  ####################################################
  # create
  ####################################################
  describe "#create" do
    before { @new_user = build(:user) }
    subject { post :create, params: { locale: :en, user: { email: @new_user.email } }, session: {} }

    context "as an existing user" do
      it "sends login email" do
        post :create, params: { locale: :en, user: { email: @user.email } }, session: {}
        expect(flash[:info]).to include("already registered")
      end
    end

    context "as a new :en user" do
      it "responds successfully" do
        subject
        expect(flash[:success]).to include("Account registered")
      end

      it "creates new user" do
        expect{ subject }.to change(User, :count).by(1)
      end

      it "creates user with default subscription" do
        expect{ subject }.to change(Subscription, :count).by(1)
      end

      it "creates user with :en params" do
        subject
        user = User.find_by(email: @new_user.email)
        expect(user.timezone).to eq 'UTC'
        expect(user.locale).to eq 'en'
      end
    end

    context "as a new :ja user" do
      it "create user with :ja params" do
        post :create, params: { locale: :ja, user: { email: @new_user.email } }, session: {}
        user = User.find_by(email: @new_user.email)
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
