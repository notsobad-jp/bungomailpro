require 'test_helper'
class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Gravatarへのリクエストmock
    stub_request(:get, /https:\/\/ja\.gravatar\.com\/.*\.json/).to_return(status: 200, body: File.read("test/fixtures/files/gravatar.json"))
  end

  test "access_show_when_guest" do
    user = users(:user1)
    get user_url(user.token)
    assert_redirected_to login_path
  end

  test "access_show_when_owner" do
    user = users(:user1)
    login_user(user)
    get user_url(user.token)
    assert_response :success
  end

  test "access_show_when_other" do
    user1 = users(:user1)
    user2 = users(:user2)
    login_user(user2)
    get user_url(user1.token)
    assert_redirected_to pro_root_path
  end
end
