module SearchHelper
  def access_count_rating(access_count)
    if access_count >= 10000
      3
    elsif access_count >= 500
      2
    elsif access_count >= 1
      1
    else
      0
    end
  end

  def access_count_stars(access_count)
    i = access_count_rating(access_count)
    content_tag(:span) do
      3.times do |j|
        outline = (j >= i) ? 'far' : 'fas' # farがoutline
        concat content_tag(:i, '', class: "fa-star yellow #{outline}")
      end
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
