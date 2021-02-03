namespace :cron do
  # 【月初】
  task update_list_subscription: :environment do |_task, _args|
    # 配信停止中のvalidなユーザーを、配信リストに(再)追加する
    paused_users = User.valid_and_paused
    Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: paused_users.pluck(:sendgrid_id))
    paused_users.update_all(list_subscribed: true)

    # 配信中のinvalidユーザーを配信リストから削除する
    invalid_users = User.invalid_and_subscribing
    invalid_users.each do |user|
      Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: user.sendgrid_id, method: :delete)
    end
    invalid_users.update_all(list_subscribed: false)
  end
end
