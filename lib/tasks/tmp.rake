namespace :tmp do
  task count_feeds: :environment do |_task, _args|
    AssignedBook.find_each do |assigned_book|
      assigned_book.update(feeds_count: assigned_book.feeds.count)
      p "Counted: #{assigned_book.id}"
    end
  end

  task generate_magic_tokens: :environment do |_task, _args|
    User.all.each do |user|
      user.generate_magic_login_token!
      p "Generated for #{user.email}: #{user.magic_login_token}"
    end
  end

  task add_scheduled_at_to_feeds: :environment do |_task, _args|
    # Feed.where(scheduled: true).each do |feed|
    #   send_at = Time.zone.parse(feed.send_at.to_s).since(feed.user.utc_offset.minutes)
    #   feed.update(scheduled_at: send_at)
    #   p "Updated feed:#{feed.id}, at: #{send_at}"
    # end
    AssignedBook.find_each do |assigned_book|
      next_feed = assigned_book.next_feed
      next_next_feed = assigned_book.feeds.find_by(index: next_feed.index+1)
      next unless next_next_feed.scheduled_at
      assigned_book.next_feed.update(scheduled_at: next_next_feed.scheduled_at.ago(1.day))
      p "Updated feed: #{next_feed.id}"
    end
  end

  task crawl: :environment do |_task, _args|
    include Rails.application.routes.url_helpers

    def get(uri)
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Get.new(uri.request_uri)
      http.request(req)
    end

    ###################################
    # 青空文庫
    ###################################
    uri = URI("https://search.bungomail.com")
    # 著者別・カテゴリ別一覧
    AozoraBook.pluck(:author_id).uniq.push("all").each do |author_id|
      AozoraBook::CATEGORIES.each do |id, category|
        path = author_category_books_path(author_id: author_id, category_id: category[:id])
        uri.path += path
        res = get uri
        p "#{res.response.code}: #{path}"
        sleep 1
      end
    end

    # 作品詳細
    AozoraBook.all.find_each do |book|
      next unless book.category_id
      path = author_category_book_path(author_id: book.author_id, category_id: book.category_id, id: book.id)
      uri.path += path
      res = get uri
      p "#{res.response.code}: #{path}"
      sleep 1
    end

    ###################################
    # Project Gutenberg
    ###################################
    uri = URI("https://search.bungomail.com")
    # 著者別・カテゴリ別一覧
    GutenBook.pluck(:author_id).uniq.push("all").each do |author_id|
      GutenBook::CATEGORIES.each do |id, category|
        path = author_category_books_path(author_id: author_id, category_id: category[:id])
        uri.path += path
        res = get uri
        p "#{res.response.code}: #{path}"
        sleep 1
      end
    end

    # 作品詳細
    GutenBook.all.find_each do |book|
      next unless book.category_id
      path = author_category_book_path(author_id: book.author_id, category_id: book.category_id, id: book.id)
      uri.path += path
      res = get uri
      p "#{res.response.code}: #{path}"
      sleep 1
    end
  end
end
