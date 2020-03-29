module SearchHelper
  def access_count_stars(star_count)
    content_tag(:span) do
      1.upto(3) do |i|
        outline = (star_count >= i) ? 'fas' : 'far' # farがoutline
        concat content_tag(:i, '', class: "fa-star yellow #{outline}")
      end
    end
  end

  def category_label(category)
    color = case category[:id]
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
      when 'shortnovel'
        'violet'
      when 'longnovel'
        'brown'
    end

    content_tag(:div, category[:name], class: "ui basic #{color} mini label")
  end

  def jsonld_breadcrumb(breadcrumbs)
    items = []
    @breadcrumbs.each.with_index(1) do |bread, index|
      items << {
        "@type": "ListItem",
        "position": index,
        "name": bread[:name],
        "item": bread[:url] || url_for(only_path: false)
      }
    end

    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items
    }.to_json
  end

  def locale_root_url
    locale = "en" if I18n.locale == :en
    search_root_url(locale: locale)
  end

  # 書き出しのtruncate文字数をlocaleで変える
  def truncated_beginning(beginning)
    beginning.truncate( (I18n.locale == :en) ? 100 : 50 )
  end
end
