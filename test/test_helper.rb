ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def stripe_signature(body)
    timestamp = Time.current.to_i
    signing_format = "#{timestamp}.#{body}"
    signature = Stripe::Webhook::Signature.send(:compute_signature, signing_format, ENV['STRIPE_WEBHOOK_SIGNATURE'])
    scheme = Stripe::Webhook::Signature::EXPECTED_SCHEME
    "t=#{timestamp},#{scheme}=#{signature}"
  end

  # Sorcery Login helper
  def login_user(user)
    get auth_url, params: { token: user.magic_login_token }
    follow_redirect!
  end
end
