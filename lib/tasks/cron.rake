namespace :cron do
  # [月初] Stripe登録状況とSubscriptionを一致させる
  task sync_stripe_subscription: :environment do |_task, _args|
    stripe_subscriptions = []
    has_more = true
    last_id = nil

    while has_more do
      list = Stripe::Subscription.list({limit: 100, starting_after: last_id})
      last_id = list.data.last&.id
      has_more = list.has_more
      stripe_subscriptions += list.data
    end
    p stripe_subscriptions
  end
end
