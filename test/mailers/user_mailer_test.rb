require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase
  def setup
    ActionMailer::Base.deliveries.clear
  end

  ########################################################################
  # send_chapter_email
  ########################################################################
  # 通常ケース
  test 'send_chapter_email_for_today' do
    sub = subscriptions(:user4_channel1)
    UserMailer.with(subscription: sub).chapter_email.deliver_now
    email = ActionMailer::Base.deliveries.last

    assert_equal ['sample4@example.com'], email.to
    assert email.header['from'].value.include? '太宰さん'
    assert email.subject.include? '走れメロス'
    assert_equal Time.current.change(hour: 22).to_i, JSON.parse(email.header['X-SMTPAPI'].value)['send_at']
  end

  # 配信日が明日なら送らない（間違って来た場合）
  test 'send_chapter_email_for_tomorrow' do
    sub = subscriptions(:user3_channel1)
    email = UserMailer.with(subscription: sub).chapter_email
    email.deliver_now

    email = ActionMailer::Base.deliveries.last
    assert_nil email
  end
end
