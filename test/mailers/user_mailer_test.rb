require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase
  def setup
    ActionMailer::Base.deliveries.clear
    stub_request(:get, %r{https://api-ssl.bitly.com/.*}).to_return(status: 200, body: '{"data":{"url":"https://hogehoge.com"}}')
    stub_request(:post, %r{https://api.line.me/.*}).to_return(status: 200, body: '')
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


  # bungomailチャネルは個別配信とグループ配信を分ける
  test 'send_chapter_email_for_bungomail' do
    sub = subscriptions(:bungomail_master)
    sub.deliver_and_update

    assert_equal 2, ActionMailer::Base.deliveries.count

    email_users = ActionMailer::Base.deliveries.first
    to = JSON.parse(email_users.header["X-SMTPAPI"].value)["to"]
    assert_equal ['sample9@example.com', 'info@notsobad.jp'].sort, to.sort

    email_group = ActionMailer::Base.deliveries.last
    to = JSON.parse(email_group.header["X-SMTPAPI"].value)["to"]
    assert_equal ['bungomail-text@notsobad.jp', 'lkxhb1yn0m.6fnhsbevhylj4@blog.hatena.ne.jp'].sort, to.sort
  end
end
