require 'test_helper'
class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    # TODO: テスト時のGravatarへのリクエストをmockする
    stub_request(:get, "https://ja.gravatar.com/45e67126a4c44c6ae030279e21437c79.json").
    with(
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host'=>'ja.gravatar.com',
        'User-Agent'=>'Ruby'
        }).
        to_return(status: 200, body: "", headers: {})
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
    assert_redirected_to login_path
  end
end
