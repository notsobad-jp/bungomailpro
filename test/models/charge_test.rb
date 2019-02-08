# == Schema Information
#
# Table name: charges
#
#  id                                                                                            :string           not null, primary key
#  user_id                                                                                       :bigint(8)        not null
#  customer_id                                                                                   :string           not null
#  brand(IN (American Express, Diners Club, Discover, JCB, MasterCard, UnionPay, Visa, Unknown)) :string           not null
#  exp_month                                                                                     :integer          not null
#  exp_year                                                                                      :integer          not null
#  last4                                                                                         :string           not null
#  subscription_id                                                                               :string
#  status(IN (trialing active past_due canceled unpaid))                                         :string
#  trial_end                                                                                     :datetime
#  cancel_at                                                                                     :datetime
#  created_at                                                                                    :datetime         not null
#  updated_at                                                                                    :datetime         not null
#

require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  ########################################################################
  # create_or_update_customer
  ########################################################################
  test 'test_create_or_update_customer_when_no_charge' do
    stub_request(:any, %r{api\.stripe\.com/v1/customers}).to_return(status: 200, body: File.read('test/fixtures/files/customer_created.json'))

    user = users(:user4)
    params = { email: user.email, source: SecureRandom.hex(10) }

    charge = Charge.find_or_initialize_by(user_id: user.id)
    charge.create_or_update_customer(params)

    assert_equal 'cus_ESCEwmXhpJdfnC', charge.customer_id
  end

  test 'test_create_or_update_customer_when_charge_exist' do
    stub_request(:any, %r{api\.stripe\.com/v1/customers}).to_return(status: 200, body: File.read('test/fixtures/files/customer_updated.json'))
    charge = charges(:charge_active)

    assert_equal 'Visa', charge.brand
    assert_equal '4242', charge.last4

    params = { email: 'hogehoge@example.com', source: SecureRandom.hex(10) } # ダミーのパラメータ（結果には影響なし）
    charge.create_or_update_customer(params)

    assert_equal 'MasterCard', charge.brand
    assert_equal '4444', charge.last4
  end

  ########################################################################
  # create_subscription
  ########################################################################
  test 'test_create_subscription_when_already_subscribing' do
    charge = charges(:charge_active)

    e = assert_raises RuntimeError do
      charge.create_subscription
    end
    assert_equal 'already subscribing', e.message
  end

  test 'test_create_subscription_succeed' do
    stub_request(:any, %r{api\.stripe\.com/v1/subscriptions}).to_return(status: 200, body: File.read('test/fixtures/files/subscription_created.json'))
    charge = charges(:charge_without_subscription)

    assert_nil charge.status
    assert_nil charge.subscription_id

    charge.create_subscription

    assert_equal 'trialing', charge.status
    assert_equal 'sub_ESBxFR0KlYTQzy', charge.subscription_id
  end

  ########################################################################
  # cancel_subscription
  ########################################################################
  test 'test_cancel_subscriptin_when_active' do
    stub_request(:any, %r{api\.stripe\.com/v1/subscriptions}).to_return(status: 200, body: File.read('test/fixtures/files/subscription_canceled.json'))
    charge = charges(:charge_active)
    charge.cancel_subscription

    assert_equal 'active', charge.status
    assert_equal Time.zone.at(1_551_797_999), charge.cancel_at
  end

  test 'test_cancel_subscriptin_when_past_due' do
    stub_request(:any, %r{api\.stripe\.com/v1/subscriptions}).to_return(status: 200, body: File.read('test/fixtures/files/subscription_deleted.json'))
    charge = charges(:charge_past_due)
    charge.cancel_subscription

    assert_equal 'canceled', charge.status
    assert_nil charge.cancel_at
  end

  ########################################################################
  # activate
  ########################################################################
  test 'test_activate_when_cancel_planned' do
    stub_request(:any, /api\.stripe\.com/).to_return(status: 200, body: File.read('test/fixtures/files/test.json'))
    charge = charges(:charge_cancel_planned)
    charge.activate

    assert_equal 'active', charge.status
    assert_nil charge.cancel_at
  end

  test 'test_activate_when_already_canceled' do
    stub_request(:any, /api\.stripe\.com/).to_return(status: 200, body: File.read('test/fixtures/files/test.json'))
    charge = charges(:charge_canceled)

    charge.activate
    assert_nil charge.cancel_at
  end

  test 'test_activate_when_still_active' do
    stub_request(:any, /api\.stripe\.com/).to_return(status: 200, body: File.read('test/fixtures/files/test.json'))
    charge = charges(:charge_active)

    charge.activate
    assert_nil charge.cancel_at
  end
end
