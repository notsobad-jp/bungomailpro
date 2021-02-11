module ApplicationHelper
  # テキスト中のリンクをaタグ化、改行をbrタグ化する
  def htmlify(text)
    URI.extract(text, ["http", "https"]).uniq.each do |url|
      text.gsub!(url, "<a target='_blank' href='#{url}'>#{url}</a>")
    end
    text.gsub!(/(\r\n|\r|\n)/, "<br />")
    text
  end
end
