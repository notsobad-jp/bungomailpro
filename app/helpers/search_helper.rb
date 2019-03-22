module SearchHelper
  def access_count_stars(access_count)
    i = 0
    if access_count > 50000
      i = 3
    elsif access_count > 10000
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
end
