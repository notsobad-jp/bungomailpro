namespace :campaigns do
  # tasks:create_campaigns BOOK_ID=xx COUNT=30 START_AT="2019-01-01 00:00:00"
  task create: :environment do |_task, _args|
    book = Book.find(ENV['BOOK_ID'])
    user = User.find_by(admin: true)
    count = ENV['COUNT'].to_i if ENV['COUNT']

    campaigns = []
    text, footnote = book.aozora_file_text
    contents = Book.split_text(text: text, count: count)
    send_at = Time.zone.parse(ENV['START_AT'])

    contents.each.with_index(1) do |content, index|
      title = "#{book.title}（#{index}/#{contents.count}） - ブンゴウメール"
      campaigns << Campaign.new(
        user_id: user.id,
        title: title,
        plain_content: content + "[unsubscribe]",
        send_at: send_at
      )
      send_at += 1.day
    end
    res = Campaign.import campaigns

    Campaign.find(res.ids).each do |campaign|
      campaign.delay(priority: 1).create_draft
      campaign.delay(priority: 2).schedule
    end
  end

  task read_file: :environment do |_task, _args|
    url = 'https://raw.githubusercontent.com/aozorabunko/aozorabunko/master/cards/000012/files/1092_20971.html'
    html = open(url, &:read)
    text, footnote = Book.new.aozora_file_text(html)
  end
end
