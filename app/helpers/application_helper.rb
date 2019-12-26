module ApplicationHelper
  require 'uri'

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

  def path
    "#{controller.controller_name}##{controller.action_name}"
  end
end
