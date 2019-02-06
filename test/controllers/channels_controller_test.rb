require 'test_helper'
class ChannelsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Gravatarへのリクエストmock
    stub_request(:get, /https:\/\/ja\.gravatar\.com\/.*\.json/).to_return(status: 200, body: File.read("test/fixtures/files/gravatar.json"))
  end

  ########################################################################
  # show
  ########################################################################
  test "access_show_when_guest" do
    channel = channels(:channel0)
    get channel_path(channel.token)
    assert_redirected_to pro_root_path
  end

  test "access_show_when_owner" do
    channel = channels(:channel0)
    login_user(channel.user)
    get channel_path(channel.token)
    assert_response :success
  end

  test "access_show_when_other" do
    channel = channels(:channel0)
    user = users(:user2)
    login_user(user)
    get channel_path(channel.token)
    assert_redirected_to pro_root_path
  end

  test "access_public_show_when_guest" do
    channel = channels(:channel3)
    get channel_path(channel.token)
    assert_response :success
  end



  ########################################################################
  # edit
  ########################################################################
  test "access_edit_when_guest" do
    channel = channels(:channel0)
    get edit_channel_path(channel.token)
    assert_redirected_to login_path
  end

  test "access_edit_when_owner" do
    channel = channels(:channel0)
    login_user(channel.user)
    get edit_channel_path(channel.token)
    assert_response :success
  end

  test "access_edit_when_other" do
    channel = channels(:channel0)
    user = users(:user2)
    login_user(user)
    get edit_channel_path(channel.token)
    assert_redirected_to pro_root_path
  end
end
