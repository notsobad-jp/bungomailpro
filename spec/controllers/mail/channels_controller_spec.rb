# require 'rails_helper'
#
# RSpec.describe Mail::ChannelsController, type: :controller do
#   before do
#     @user = create(:user)
#   end
#
#   describe "#show" do
#     context "as a guest" do
#       it "returns a 302 response" do
#         get :show, params: {id: @user}
#         expect(response).to redirect_to login_url
#         expect(response).to have_http_status "302"
#       end
#     end
#
#     context "as an other user" do
#       it "returns a 302 response" do
#         get :show, params: {id: @user}
#         expect(response).to redirect_to login_url
#         expect(response).to have_http_status "302"
#       end
#     end
#
#     context "as an owner" do
#       it "responds successfully" do
#         login_user(@user)
#         get :show, params: {id: @user}
#         expect(response).to be_successful
#       end
#     end
#   end
# end
