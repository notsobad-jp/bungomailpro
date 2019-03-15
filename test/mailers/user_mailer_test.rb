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

  # 非PROユーザーにはメール送信しない
  test 'send_chapter_email_for_non_pro' do
    sub = subscriptions(:user4_channel1)
    UserMailer.with(subscription: sub).chapter_email.deliver_now
    email = ActionMailer::Base.deliveries.last
    assert_nil email
  end

  # streamingチャネルでは、PROユーザーにのみメール送信する
  test 'send_chapter_email_for_streaming' do
    sub = subscriptions(:streaming_master)
    UserMailer.with(subscription: sub).chapter_email.deliver_now
    email = ActionMailer::Base.deliveries.last
    to = JSON.parse(email.header["X-SMTPAPI"].value)["to"]

    assert_equal ['sample7@example.com', 'sample8@example.com'], to
  end

  # ALTER EGOチャネルでは送信元をカスタマイズ
  test 'send_chapter_email_for_alterego' do
    sub = subscriptions(:alterego_master)
    UserMailer.with(subscription: sub).chapter_email.deliver_now
    email = ActionMailer::Base.deliveries.last
    to = JSON.parse(email.header["X-SMTPAPI"].value)["to"]

    assert_equal ['alterego@bungomail.com'], to
    assert email.header['from'].value.include? 'エス'
    assert email.header['from'].value.include? 'alterego@notsobad.jp'
    assert email.subject.include? '太宰さん'
  end
end
