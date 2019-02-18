module ApplicationHelper
  require 'uri'

  def channel_status_icon(status)
    case status
    when 'private'
      icon_tag = content_tag(:i, nil, class: "icon small lock")
      content_tag(:small, icon_tag, data: { tooltip: "非公開", inverted: true })
    when 'streaming'
      content_tag(:label, "ストリーミング配信", class: "ui blue small basic label", data: { tooltip: "このチャネルは全員に同じタイミングで配信されます", inverted: true })
    end
  end

  def creditcard_icon(brand)
    brand = brand.downcase
    case brand
    when 'diners club', 'discover', 'jcb', 'mastercard', 'visa'
      content_tag(:i, nil, class: "icon big cc #{brand}")
    when 'american express'
      content_tag(:i, nil, class: 'icon big cc amex')
    else
      content_tag(:i, nil, class: 'icon big credit card')
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

  def linknize(text)
    URI.extract(text, %w[http https]).uniq.each do |url|
      sub_text = ''
      sub_text << '<a href=' << url << ' target="_blank">' << url << '</a>'
      text.gsub!(url, sub_text)
    end
    text
  end

  def payment_status_label(charge)
    return content_tag(:span, 'FREEプラン', class: 'ui basic label') if charge.try(:cancel_at)

    case charge.try(:status)
    when 'trialing'
      content_tag(:span, '無料トライアル中', class: 'ui orange label')
    when 'active'
      content_tag(:span, 'PROプラン', class: 'ui orange label')
    when 'past_due'
      content_tag(:span, '決済失敗', class: 'ui red basic label')
    when 'canceled'
      content_tag(:span, 'FREEプラン', class: 'ui basic label')
    else
      content_tag(:span, 'FREEプラン', class: 'ui basic label')
    end
  end

  def path
    "#{controller.controller_name}##{controller.action_name}"
  end

  def simple_format_with_link(text)
    simple_format(sanitize(linknize(text), attributes: %w[href target]), {}, sanitize: false) if text
  end

  def streaming_subscribed_button(master_subscription)
    if master_subscription.not_started?
      small = content_tag(:small, "（ #{ @master_sub.next_delivery_date.strftime('%-m月%-d日') } 配信開始）")
      content_tag(:button, "配信予約済み #{small}", class: 'ui red disabled button')
    else
      content_tag(:button, "配信中", class: 'ui red disabled button')
    end
  end

  def footer_hidden
    return 'hidden' if controller_name == 'channels' && %w[new edit create update].include?(action_name)
  end

  def time_select
    times = {}
    (4..23).each do |i|
      times["#{i}:00"] = i
    end
    times
  end
end
