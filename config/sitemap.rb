# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://search.bungomail.com'
SitemapGenerator::Sitemap.create do
  ####################################################################
  # 青空文庫
  ####################################################################
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

    case book.popularity
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


  ####################################################################
  # 青空文庫 for Kids
  ####################################################################
  # 著者指定なしのカテゴリ別一覧
  AozoraBook::CATEGORIES.each do |id, category|
    priority = 1.0
    add author_category_books_path(author_id: 'all', category_id: category[:id], juvenile: 'juvenile'), priority: priority, changefreq: 'weekly'
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
      add author_category_books_path(author_id: author_id, category_id: category[:id], juvenile: 'juvenile'), priority: priority, changefreq: 'weekly'
    end
  end

  # 作品詳細
  AozoraBook.all.find_each do |book|
    next unless book.category_id

    case book.popularity
    when 300000 .. Float::INFINITY
      priority = 0.7
    when 100000 .. 300000
      priority = 0.6
    when 30000 .. 100000
      priority = 0.5
    else
      priority = 0.3
    end

    add author_category_book_path(author_id: book.author_id, category_id: book.category_id, id: book.id, juvenile: 'juvenile'), priority: priority, changefreq: 'weekly'
  end


  ####################################################################
  # Gutenberg
  ####################################################################
  # 著者指定なしのカテゴリ別一覧
  GutenBook::CATEGORIES.each do |id, category|
    priority = 1.0
    add author_category_books_path(author_id: 'all', category_id: category[:id], locale: :en), priority: priority, changefreq: 'weekly'
  end

  # 著者別・カテゴリ別一覧
  @popular_authors = GutenBook.popular_authors(150)
  GutenBook.pluck(:author_id).uniq.each do |author_id|
    case @popular_authors[author_id] || 0
    when 100 .. Float::INFINITY
      priority = 1.0
    when 50 .. 100
      priority = 0.8
    when 1 .. 50
      priority = 0.7
    else
      priority = 0.4
    end

    GutenBook::CATEGORIES.each do |id, category|
      next unless GutenBook.where(author_id: author_id, category_id: category[:id]).exists?
      add author_category_books_path(author_id: author_id, category_id: category[:id], locale: :en), priority: priority, changefreq: 'weekly'
    end
  end

  # 作品詳細
  GutenBook.all.find_each do |book|
    next unless book.category_id

    case book.popularity
    when 100 .. Float::INFINITY
      priority = 0.7
    when 50 .. 100
      priority = 0.6
    when 1 .. 50
      priority = 0.5
    else
      priority = 0.3
    end

    add author_category_book_path(author_id: book.author_id, category_id: book.category_id, id: book.id, locale: :en), priority: priority, changefreq: 'weekly'
  end
end
