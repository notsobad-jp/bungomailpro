namespace :tmp do
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
