module SearchHelper
  def access_count_stars(access_count)
    i = 0
    if access_count >= 10000
      i = 3
    elsif access_count >= 500
      i = 2
    elsif access_count >= 1
      i = 1
    end

    content_tag(:span) do
      3.times do |j|
        outline = 'outline' if j >= i
        concat content_tag(:i, '', class: "icon yellow #{outline} star")
      end
      i.times do |num|
        concat content_tag(:span, '★', class: "amp only")
      end
    end
  end

  def amp_url
    # root_urlのときは.ampだとうまくいかないので/authors/all/categories/all/booksをamp_urlにする
    uri = (request.url == root_url(subdomain: 'search')) ? author_category_books_url(author_id: 'all', category_id: 'all') : request.url
    amp_uri = URI.parse(uri)
    amp_uri.path = "#{amp_uri.path}.amp"
    amp_uri.to_s.html_safe
  end

  def amp_canonical_url
    if (url = request.url.gsub(".amp", "")) == author_category_books_url(author_id: 'all', category_id: 'all')
      root_url(subdomain: 'search')
    else
      url
    end
  end

  def characters_range(category)
    range_from = category.range_from.to_s(:delimited)
    range_to = category.range_to.to_s(:delimited)

    case category.id
    when 'all'
      ""
    when 'flash'
      "〜#{range_to}文字"
    when 'novel'
      "#{range_from}文字〜"
    else
      "#{range_from}〜#{range_to}文字"
    end
  end

  def category_label(category)
    color = case category.id
      when 'flash'
        'orange'
      when 'shortshort'
        'pink'
      when 'short'
        'blue'
      when 'novelette'
        'green'
      when 'novel'
        ''
    end

    content_tag(:div, category.name, class: "ui basic #{color} mini label")
  end
end
