class MembershipsController < ApplicationController
  def new
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      mode: 'setup',
      customer_email: current_user.email,
      success_url: mypage_url, # FIXME: 決済完了ページを用意する
      cancel_url: new_membership_url,
    )
    @meta_title = '決済情報の登録'
    @no_index = true
  end
end
