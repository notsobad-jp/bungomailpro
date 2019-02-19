require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase
  def setup
    ActionMailer::Base.deliveries.clear
  end

  ########################################################################
  # send_chapter_email
  ########################################################################
  # PROユーザーにはメールを送信する
  test 'send_chapter_email_for_today' do
    sub = subscriptions(:user1_channel1)
    UserMailer.with(subscription: sub).chapter_email.deliver_now
    email = ActionMailer::Base.deliveries.last
    to = JSON.parse(email.header["X-SMTPAPI"].value)["to"]

    assert_equal ['sample@example.com'], to
    assert email.header['from'].value.include? '太宰さん'
    assert email.subject.include? '走れメロス'
    assert_equal Time.current.change(hour: 8).to_i, JSON.parse(email.header['X-SMTPAPI'].value)['send_at']
  end

  # TODO: 非PROユーザーの制限は2019年3月まで無効
  # # 非PROユーザーにはメール送信しない
  # test 'send_chapter_email_for_non_pro' do
  #   sub = subscriptions(:user4_channel1)
  #   UserMailer.with(subscription: sub).chapter_email.deliver_now
  #   email = ActionMailer::Base.deliveries.last
  #   assert_nil email
  # end
  #
  # # streamingチャネルでは、PROユーザーにのみメール送信する
  # test 'send_chapter_email_for_streaming' do
  #   sub = subscriptions(:streaming_master)
  #   UserMailer.with(subscription: sub).chapter_email.deliver_now
  #   email = ActionMailer::Base.deliveries.last
  #   to = JSON.parse(email.header["X-SMTPAPI"].value)["to"]
  #
  #   assert_equal ['sample7@example.com', 'sample8@example.com'], to
  # end

  # 配信日が明日なら送らない（間違って送信処理まで来ちゃった場合）
  test 'send_chapter_email_for_tomorrow' do
    sub = subscriptions(:user3_channel1)
    UserMailer.with(subscription: sub).chapter_email.deliver_now
    email = ActionMailer::Base.deliveries.last
    assert_nil email
  end
end
