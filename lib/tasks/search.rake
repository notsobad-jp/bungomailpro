namespace :search do
  desc 'ゾラサーチの全ページにアクセスしてCDNにキャッシュさせる'
  task access_all_pages: :environment do |_task, _args|
    host = 'https://search.bungomail.com'

    @popular_authors = Book.limit(150).order('sum_access_count desc').group(:author_id).sum(:access_count).map{|id,sum| id}
    @popular_authors.each do |author_id|
      Category.all.each do |category|
        uri = URI.parse("#{host}/authors/#{author_id}/categories/#{category.id}/books")
        response = get_url(uri)
        p "[#{response.code}] #{uri}"
        sleep 1
      end
    end
  end


  def get_url(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.get('/')
    end
  end
end
