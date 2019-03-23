module SearchHelper
  def access_count_stars(access_count)
    i = 0
    if access_count > 10000
      i = 3
    elsif access_count > 500
      i = 2
    elsif access_count > 1
      i = 1
    end

    content_tag(:div) do
      i.times do |j|
        concat content_tag(:i, '', class: 'icon yellow star')
      end
    end
  end

  def characters_range(category)
    range_from = category.range_from.to_s(:delimited)
    range_to = category.range_to.to_s(:delimited)

    case category.id
    when 'flash'
      "〜#{range_to}文字"
    when 'novel'
      "#{range_from}文字〜"
    else
      p category
      "#{range_from}〜#{range_to}文字"
    end
  end
end
