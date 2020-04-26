require 'rails_helper'

RSpec.describe Mail::SearchConditionsController, type: :controller do
  before do
    @condition = create(:search_condition)
  end

  ####################################################
  # index
  ####################################################
  describe "#index" do
    subject { get :index, params: { locale: :en }, session: {} }

    context "as a guest" do
      it "returns a 302 response" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as an other user" do
      render_views
      before { login_user(create(:user)) }

      it "responds successfully" do
        subject
        expect(response).to be_successful
      end

      it "does not show other user's contents" do
        subject
        expect(response.body).not_to include("Janeway")
      end
    end

    context "as an owner" do
      render_views
      before { login_user(@condition.user) }

      it "responds successfully" do
        subject
        expect(response).to be_successful
      end

      it "shows owned contents" do
        subject
        expect(response.body).to include("Janeway")
      end
    end
  end


  ####################################################
  # create
  ####################################################
  describe "#create" do
    subject { post :create, params: { locale: :en, query: {author: "Rowlandson"}, book_type: "GutenBook" }, session: {} }

    context "as a guest" do
      it "returns a 302 response" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as a user" do
      before { login_user(@condition.user) }

      it "responds successfully" do
        subject
        expect(flash[:success]).to include("Saved the condition")
      end

      it "creates new content" do
        expect{ subject }.to change(SearchCondition, :count).by(1)
      end
    end
  end


  ####################################################
  # destroy
  ####################################################
  describe "#destroy" do
    subject { delete :destroy, params: { locale: :en, id: @condition.id }, session: {} }

    context "as a guest" do
      it "returns a 302 response" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as an other user" do
      before { login_user(create(:user)) }

      it "responds successfully" do
        subject
        expect(response).to redirect_to login_url
        expect(response).to have_http_status "302"
      end
    end

    context "as an owner" do
      before { login_user(@condition.user) }

      it "responds successfully" do
        subject
        expect(flash[:success]).to include("Deleted")
      end

      it "deletes the content" do
        expect{ subject }.to change(SearchCondition, :count).by(-1)
      end
    end
  end
end
