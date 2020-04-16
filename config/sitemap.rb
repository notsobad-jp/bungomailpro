# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://search.bungomail.com'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  # 著者指定なしのカテゴリ別一覧
  AozoraBook::CATEGORIES.each do |id, category|
    priority = 1.0
    add author_category_books_path(author_id: 'all', category_id: category[:id]), priority: priority, changefreq: 'weekly'
  end

  # 著者別・カテゴリ別一覧
  @popular_authors = AozoraBook.popular_authors(150)
  AozoraBook.pluck(:author_id).uniq.each do |author_id|
    case @popular_authors[author_id] || 0
    when 300000 .. Float::INFINITY
      priority = 1.0
    when 50000 .. 300000
      priority = 0.8
    when 1 .. 50000
      priority = 0.7
    else
      priority = 0.4
    end

    AozoraBook::CATEGORIES.each do |id, category|
      next unless AozoraBook.where(author_id: author_id, category_id: category[:id]).exists?
      add author_category_books_path(author_id: author_id, category_id: category[:id]), priority: priority, changefreq: 'weekly'
    end
  end

  # 作品詳細
  AozoraBook.all.find_each do |book|
    next unless book.category_id

    case book.access_count
    when 300000 .. Float::INFINITY
      priority = 0.7
    when 100000 .. 300000
      priority = 0.6
    when 30000 .. 100000
      priority = 0.5
    else
      priority = 0.3
    end

    add author_category_book_path(author_id: book.author_id, category_id: book.category_id, id: book.id), priority: priority, changefreq: 'weekly'
  end
end
