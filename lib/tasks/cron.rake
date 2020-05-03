namespace :cron do
  # 【月初】
  task update_list_subscription: :environment do |_task, _args|
    ## 配信停止中のユーザーを配信リストに(再)追加する
    #### 対象: 一時停止中の課金ユーザー || お試し期間中のユーザー
    # users = User.where(list_subscribed: false)
    # Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: users.pluck(:sendgrid_id))

    ## 配信中のユーザーを配信リストから削除する
    #### 対象: お試し期間が終了した非課金ユーザー
    # users = User.where(list_subscribed: true).unpaid.trial_ended
    # users.each do |user|
    #   Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: user.sendgrid_id), method: :delete)
    # end
  end
end
