namespace :cron do
  # 【月初】
  task update_list_subscription: :environment do |_task, _args|
    # 配信停止中のvalidなユーザーを、配信リストに(再)追加する
    Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: User.valid_and_paused.pluck(:sendgrid_id))

    # 配信中のinvalidユーザーを配信リストから削除する
    User.invalid_and_subscribing.each do |user|
      Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: user.sendgrid_id, method: :delete)
    end
  end
end
