require 'test_helper'
class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Gravatarへのリクエストmock
    stub_request(:get, %r{https://ja\.gravatar\.com/.*\.json}).to_return(status: 200, body: File.read('test/fixtures/files/gravatar.json'))
  end


  ########################################################################
  # index
  ########################################################################
  test 'access_index_when_guest' do
    get subscriptions_path
    assert_response :success
  end

  test 'access_index_when_login' do
    login_user(users(:user1))
    get subscriptions_path
    assert_response :success
  end


  ########################################################################
  # edit
  ########################################################################
  test 'access_edit_when_guest' do
    sub = subscriptions(:user1_channel1)
    get edit_subscription_path(sub)
    assert_response 401
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
    assert_response 403
  end

  test 'access_edit_when_streaming_user' do
    sub = subscriptions(:streaming_master)
    login_user(users(:user8))
    get edit_subscription_path(sub)
    assert_response 403
  end

  test 'access_edit_when_streaming_user_owned' do
    sub = subscriptions(:streaming_active)
    login_user(sub.user)
    get edit_subscription_path(sub)
    assert_response 403
  end

  test 'access_edit_when_streaming_owner' do
    sub = subscriptions(:streaming_master)
    login_user(users(:user7))
    get edit_subscription_path(sub)
    assert_response :success
  end


  ########################################################################
  # update
  ########################################################################
  test 'access_update_when_streaming_user_owned' do
    sub = subscriptions(:streaming_active)
    login_user(sub.user)
    put subscription_path(id: sub.id), params: { subscription: { delivery_hour: 13 } }
    sub = Subscription.find(sub.id)
    refute_equal 13, sub.delivery_hour
  end

  test 'access_update_when_streaming_user_master' do
    sub = subscriptions(:streaming_master)
    login_user(users(:user8))
    put subscription_path(id: sub.id), params: { subscription: { delivery_hour: 13 } }
    sub = Subscription.find(sub.id)
    refute_equal 13, sub.delivery_hour
  end

  test 'access_update_when_streaming_master' do
    sub = subscriptions(:streaming_master)
    login_user(users(:user7))
    put subscription_path(id: sub.id), params: { subscription: { delivery_hour: 13 } }
    sub = Subscription.find(sub.id)
    assert_equal 13, sub.delivery_hour
  end


  ########################################################################
  # destroy
  ########################################################################
  test 'access_destroy_when_user' do
    sub = subscriptions(:user1_channel1)
    login_user(sub.user)
    delete subscription_path(id: sub.id)
    sub = Subscription.find_by(id: sub.id)
    assert_nil sub
  end

  test 'access_destroy_when_streaming_user_onwed' do
    sub = subscriptions(:streaming_active)
    login_user(sub.user)
    delete subscription_path(id: sub.id)
    sub = Subscription.find_by(id: sub.id)
    assert_nil sub
  end

  test 'access_destroy_when_streaming_master' do
    sub = subscriptions(:streaming_master)
    login_user(sub.user)
    delete subscription_path(id: sub.id)
    sub = Subscription.find_by(id: sub.id)
    refute_nil sub
    assert_response 403
  end
end
