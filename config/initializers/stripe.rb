Rails.configuration.stripe = {
  :publishable_key => Rails.env.production? ? ENV['STRIPE_PUBLISHABLE_KEY'] : ENV['STRIPE_PUBLISHABLE_KEY_TEST'],
  :secret_key => Rails.env.production? ? ENV['STRIPE_SECRET_KEY'] : ENV['STRIPE_SECRET_KEY_TEST']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
