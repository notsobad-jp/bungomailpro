require 'test_helper'
class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "webhook_with_bad_format" do
    body = File.read("test/fixtures/files/webhook_invalid.json")
    sig_header = stripe_signature(body)

    post webhooks_update_subscription_url, params: body, headers: { "CONTENT_TYPE" => 'application/json', 'HTTP_STRIPE_SIGNATURE' => sig_header }
    assert_response :bad_request
  end


  test "webhook_with_bad_signature" do
    body = File.read("test/fixtures/files/webhook_trial_ended.json")
    sig_header = "t=1549267148,v1=hogehoge,v0=fugafuga"

    post webhooks_update_subscription_url, params: body, headers: { "CONTENT_TYPE" => 'application/json', 'HTTP_STRIPE_SIGNATURE' => sig_header }
    assert_response :bad_request
  end


  test "webhook_when_status_not_changed" do
    charge = charges(:charge_trialing)
    assert_equal  'trialing', charge.status

    body = File.read("test/fixtures/files/webhook_status_not_changed.json")
    sig_header = stripe_signature(body)
    post webhooks_update_subscription_url, params: body, headers: { "CONTENT_TYPE" => 'application/json', 'HTTP_STRIPE_SIGNATURE' => sig_header }

    assert_response :success
    charge = Charge.find(charge.id)
    assert_equal  'trialing', charge.status
  end


  test "webhook_when_trial_ended" do
    charge = charges(:charge_trialing)
    assert_equal  'trialing', charge.status

    body = File.read("test/fixtures/files/webhook_trial_ended.json")
    sig_header = stripe_signature(body)
    post webhooks_update_subscription_url, params: body, headers: { "CONTENT_TYPE" => 'application/json', 'HTTP_STRIPE_SIGNATURE' => sig_header }

    assert_response :success
    charge = Charge.find(charge.id)
    assert_equal  'active', charge.status
  end


  test "webhook_when_payment_failed" do
    charge = charges(:charge_active)
    assert_equal  'active', charge.status

    body = File.read("test/fixtures/files/webhook_payment_failed.json")
    sig_header = stripe_signature(body)
    post webhooks_update_subscription_url, params: body, headers: { "CONTENT_TYPE" => 'application/json', 'HTTP_STRIPE_SIGNATURE' => sig_header }

    assert_response :success
    charge = Charge.find(charge.id)
    assert_equal  'past_due', charge.status
  end


  test "webhook_when_payment_succeeded_after_failure" do
    charge = charges(:charge_past_due)
    assert_equal  'past_due', charge.status

    body = File.read("test/fixtures/files/webhook_payment_succeeded_after_failure.json")
    sig_header = stripe_signature(body)
    post webhooks_update_subscription_url, params: body, headers: { "CONTENT_TYPE" => 'application/json', 'HTTP_STRIPE_SIGNATURE' => sig_header }

    assert_response :success
    charge = Charge.find(charge.id)
    assert_equal  'active', charge.status
  end


  test "webhook_when_payment_canceled_after_failure" do
    charge = charges(:charge_past_due)
    assert_equal  'past_due', charge.status

    body = File.read("test/fixtures/files/webhook_payment_canceled_after_failure.json")
    sig_header = stripe_signature(body)
    post webhooks_update_subscription_url, params: body, headers: { "CONTENT_TYPE" => 'application/json', 'HTTP_STRIPE_SIGNATURE' => sig_header }

    assert_response :success
    charge = Charge.find(charge.id)
    assert_equal  'canceled', charge.status
  end
end
