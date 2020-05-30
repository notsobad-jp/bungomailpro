namespace :campaign_groups do
  task create: :environment do |_task, _args|
    sender = Sender.where("locked_until < ?", Time.current).or(Sender.where(locked_until: nil)).first

    # CampaignGroup作成
    CampaignGroup.create(
      book_id: ENV['BOOK_ID'],
      count: ENV['COUNT'],
      start_at: ENV['START_AT'],
      list_id: CampaignGroup::LIST_ID,
      sender_id: sender.id,
    )

    # Sender情報をDBとSendgrid両方でアップデート
    book = AozoraBook.find(ENV['BOOK_ID'])
    author_name =  "#{book.author_name}（ブンゴウメール）"
    locked_until = Time.zone.parse(ENV['START_AT']).since((ENV['COUNT'].to_i - 1).days)
    sender.update(name: author_name, locked_until: locked_until)
    Sendgrid.call(path: "senders/#{sender.id}", method: :patch, params: { from: { name: author_name }, reply_to: { name: author_name } })

    p "Created #{book.title} campaign and updated sender name to #{author_name}"
  end
end
