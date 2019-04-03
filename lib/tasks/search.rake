namespace :search do
  desc 'ゾラサーチの全ページにアクセスしてCDNにキャッシュさせる'
  task access_all_pages: :environment do |_task, _args|
    host = 'https://search.bungomail.com'

    Book.pluck(:author_id).uniq.push('all').each do |author_id|
      Category.all.each do |category|
        uri = URI.parse("#{host}/authors/#{author_id}/categories/#{category.id}/books")
        response = get_url(uri)
        p "[#{response.code}] #{uri}"
        sleep 1
      end
    end

    Book.includes(:category).all.find_each do |book|
      uri = URI.parse("#{host}/authors/#{book.author_id}/categories/#{book.category.id}/books/#{book.id}")
      response = get_url(uri)
      p "[#{response.code}] #{uri}"
      sleep 1
    end
  end


  def get_url(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.get('/')
    end
  end
end
