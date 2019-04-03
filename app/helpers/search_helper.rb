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
