# == Schema Information
#
# Table name: users
#
#  id                             :uuid             not null, primary key
#  category(IN (admin partner))   :string
#  crypted_password               :string
#  email                          :string           not null
#  magic_login_email_sent_at      :datetime
#  magic_login_token              :string
#  magic_login_token_expires_at   :datetime
#  pixela_logging                 :boolean          default(FALSE)
#  remember_me_token              :string
#  remember_me_token_expires_at   :datetime
#  salt                           :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_users_on_email              (email) UNIQUE
#  index_users_on_magic_login_token  (magic_login_token)
#  index_users_on_remember_me_token  (remember_me_token)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)
    @user3 = users(:user3)
  end

  ########################################################################
  # subscriptionable?
  ########################################################################
  # 購読チャネルが5未満のとき
  test 'subscriptionable?_when_true' do
    @user1.subscribe(channels(:channel3))
    assert_equal 3, @user1.subscriptions.size
    assert @user1.subscriptionable?
  end

  # 購読チャネルが5以上のとき
  test 'subscriptionable?_when_false' do
    @user1.subscribe(channels(:channel3))
    @user1.subscribe(channels(:channel4))
    @user1.subscribe(channels(:streaming))

    assert_equal 5, @user1.subscriptions.size
    assert_not @user1.subscriptionable?
  end

  ########################################################################
  # subscribe
  ########################################################################
  # 自分の非公開チャネル
  test 'subscribe_own_private_channel' do
    assert_equal 2, @user3.subscriptions.size
    @user3.subscribe(channels(:channel3))
    assert_equal 3, @user3.subscriptions.size
  end

  # 他ユーザーの公開チャネル
  test 'subscribe_others_public_channel' do
    assert_equal 2, @user1.subscriptions.size
    @user1.subscribe(channels(:channel3))
    assert_equal 3, @user1.subscriptions.size
  end

  # 購読済みのチャネル
  test 'subscribe_duplicate_channel' do
    assert_equal 2, @user1.subscriptions.size
    @user1.subscribe(channels(:channel1))
    assert_equal 2, @user1.subscriptions.size
  end

  # 他ユーザーの非公開チャネル
  ## TODO: 非公開チャネルの購読はとりあえずviews側で制御。ステータスの再変更とか考えないといけないので、modelレベルでの制御は後回し。

  # すでに3つ購読しているとき
  ## TODO: validates_associatedがminitestでうまく機能しないので後回し
end
