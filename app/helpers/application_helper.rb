module ApplicationHelper
  require "uri"


  def creditcard_icon(brand)
    brand = brand.downcase
    case brand
      when 'diners club', 'discover', 'jcb', 'mastercard', 'visa'
        content_tag(:i, nil, class: "icon big cc #{brand}")
      when 'american express'
        content_tag(:i, nil, class: "icon big cc amex")
      else
        content_tag(:i, nil, class: "icon big credit card")
    end
  end

  def delivery_hours
    delivery_hours = {}
    (3..22).each do |h|
      delivery_hours["#{h}:00"] = h
    end
    delivery_hours
  end

  def delivery_period_label(chapters_count)
    if chapters_count >= 30
      content = "#{chapters_count.div(30)}ヶ月"
      content_tag(:span, content, class: 'ui mini label')
    else
      content = "#{chapters_count}日"
      content_tag(:span, content, class: 'ui mini basic label')
    end
  end

  def linknize text
    URI.extract(text, ['http', 'https']).uniq.each do |url|
      sub_text = ""
      sub_text << "<a href=" << url << " target=\"_blank\">" << url << "</a>"
      text.gsub!(url, sub_text)
    end
    text
  end

  def payment_status_label(charge)
    return content_tag(:span, '解約済み', class: 'ui basic label') if charge.cancel_at

    case charge.try(:status)
      when 'trialing'
        content_tag(:span, '無料トライアル中', class: 'ui orange label')
      when 'active'
        content_tag(:span, 'PROプラン', class: 'ui orange label')
      when 'past_due'
        content_tag(:span, '決済失敗', class: 'ui red basic label')
      when 'canceled'
        content_tag(:span, '解約済み', class: 'ui basic label')
      else
        content_tag(:span, 'FREEプラン', class: 'ui basic label')
    end
  end

  def path
    "#{controller.controller_name}##{controller.action_name}"
  end

  def simple_format_with_link text
    simple_format(sanitize(linknize(text), attributes: ["href", "target"]), {}, sanitize: false) if text
  end

  def footer_hidden
    return 'hidden' if controller_name == 'channels' && %w(new edit create update).include?(action_name)
  end

  def time_select
    times = {}
    (4..23).each do |i|
      times["#{i}:00"] = i
    end
    times
  end
end
