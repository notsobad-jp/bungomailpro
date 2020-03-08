require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "generate magic_token after creation" do
    user = User.create(email: 'hoge@example.com')
    assert user.magic_login_token.present?
  end

  test "current_book_assignment" do
    user1 = users(:user1)
    assert_equal user1.current_book_assignment, book_assignments(:current)
  end

  test "select_book" do
    # TODO: DBにbooksのデータを入れて、セレクトしたのが条件満たしてることを確認
    # assert User.new.select_book
  end

  test "utc_offset: 09:30 in Tokyo" do
    ## delivery_time: 09:30 => 570
    ## tz_offset: Tokyo(+09:00) => 540
    user = User.new(timezone: 'Tokyo', delivery_time: '09:30')
    assert_equal 30, user.utc_offset
  end

  test "utc_offset: 10:00 in Hawaii" do
    ## delivery_time: 10:00 => 600
    ## tz_offset: Hawaii(-10:00) => 600
    user = User.new(timezone: 'Hawaii', delivery_time: '10:00')
    assert_equal 1200, user.utc_offset
  end

  # 00:00より前になるときは、後ろから折り返し
  test "utc_offset: 01:00 in Tokyo" do
    ## delivery_time: 01:00 => 60
    ## tz_offset: Tokyo(+09:00) => 540
    user = User.new(timezone: 'Tokyo', delivery_time: '01:00')
    assert_equal (24*60 - 480), user.utc_offset
  end

  # 24:00より後ろになるときは、前から折り返し
  test "utc_offset: 20:00 in Hawaii" do
    ## delivery_time: 20:00 => 1200
    ## tz_offset: Hawaii(-10:00) => 600
    user = User.new(timezone: 'Hawaii', delivery_time: '20:00')
    assert_equal (1800 - 24*60), user.utc_offset
  end
end
