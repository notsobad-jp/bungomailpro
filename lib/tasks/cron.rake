namespace :cron do
  # [月初] Stripe登録状況とSubscriptionを一致させる
  task sync_stripe_subscription: :environment do |_task, _args|
    emails = []
    has_more = true
    last_id = nil

    while has_more do
      list = Stripe::Subscription.list({limit: 100, starting_after: last_id, expand: ['data.customer']})
      last_id = list.data.last&.id
      has_more = list.has_more
      emails += list.data.map{|m| m.customer.email}
    end

    subscribed_users = User.where(email: emails)
    user_ids = subscribed_users.map(&:id)

    p "Subscribed users: #{user_ids.length}"

    canceled_subs = Subscription.where.not(user_id: user_ids)
    p "Canceled subs: #{canceled_subs.length}"
    canceled_subs.delete_all

    records = []
    user_ids.each do |user_id|
      records << { user_id: user_id, channel_id: Channel::OFFICIAL_CHANNEL_ID }
    end
    Subscription.upsert_all(records, unique_by: %i[user_id channel_id])
    p "Total sub: #{Subscription.all.count}"
  end
end
