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
    sender.update(name: "#{book.author_name}（ブンゴウメール）")
    Sendgrid.call(path: "senders/#{sender.id}", method: :patch, params: { from: { name: book.author_name }, reply_to: { name: book.author_name } })

    p "Created #{book.title} campaign and updated sender name to #{book.author_name}"
  end
end
