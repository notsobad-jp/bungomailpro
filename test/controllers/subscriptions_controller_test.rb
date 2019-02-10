require 'test_helper'
class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Gravatarへのリクエストmock
    stub_request(:get, %r{https://ja\.gravatar\.com/.*\.json}).to_return(status: 200, body: File.read('test/fixtures/files/gravatar.json'))
  end

  ########################################################################
  # edit
  ########################################################################
  test 'access_edit_when_guest' do
    sub = subscriptions(:user1_channel1)
    get edit_subscription_path(sub)
    assert_redirected_to login_path
  end

  test 'access_edit_when_owner' do
    sub = subscriptions(:user1_channel1)
    login_user(sub.user)
    get edit_subscription_path(sub)
    assert_response :success
  end

  test 'access_edit_when_other' do
    sub = subscriptions(:user1_channel1)
    user = users(:user2)
    login_user(user)
    get edit_subscription_path(sub)
    assert_redirected_to pro_root_path
  end
end
