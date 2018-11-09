module ApplicationHelper
  require "uri"

  def linknize text
    URI.extract(text, ['http', 'https']).uniq.each do |url|
      sub_text = ""
      sub_text << "<a href=" << url << " target=\"_blank\">" << url << "</a>"
      text.gsub!(url, sub_text)
    end
    text
  end

  def simple_format_with_link text
    simple_format(sanitize(linknize(text), attributes: ["href", "target"]), {}, sanitize: false)
  end

  def footer_hidden
    return 'hidden' if controller_name == 'courses' && %w(new edit).include?(action_name)
  end

  def label_class user_course_status
    case user_course_status
    when 1
      'orange'
    when 2
      'yellow'
    else
      'default'
    end
  end

  def label_name user_course_status
    case user_course_status
    when 1
      '購読中'
    when 2
      '停止中'
    else
      '配信終了'
    end
  end
end
