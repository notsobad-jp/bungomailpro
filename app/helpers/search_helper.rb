module SearchHelper
  def access_count_stars(star_count)
    content_tag(:span) do
      1.upto(3) do |i|
        outline = (star_count >= i) ? 'fas' : 'far' # farがoutline
        concat content_tag(:i, '', class: "fa-star yellow #{outline}")
      end
    end
  end

  def characters_range(category)
    range_from = category[:range_from].to_s(:delimited)
    range_to = category[:range_to].to_s(:delimited)

    case category[:id]
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
end
