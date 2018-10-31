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
end
