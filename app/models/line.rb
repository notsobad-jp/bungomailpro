class Line
  LINE_BASE_URL = 'https://api.line.me/v2/bot/message/broadcast'

  def self.broadcast(chapter)
    uri = URI.parse(LINE_BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    headers = {
      'Authorization'=>"Bearer { #{ENV['LINE_CHANNEL_TOKEN']} }",
      'Content-Type' =>'application/json',
    }
    req = Net::HTTP::Post.new(uri.path, headers)

    text = "#{chapter.book.author.tr(',', '、')}『#{chapter.book.title}』（#{chapter.index}/#{chapter.book.chapters_count}）"
    text += "\r\n-----------------\r\n"
    text += chapter.text
    contents = text.each_char.each_slice(500).map(&:join)
    contents.each_with_index do |content, index|
      next if index+1 == contents.length
      contents[index] = content[0, content.rindex("。")+1] # 最後の。までで切る
      contents[index + 1].insert(0, content[content.rindex("。")+1, content.length]) # 切った分を次のcontentの先頭に追加
    end if contents.count > 1

    req.body = {
      "messages": contents.map{ |t| {"type":"text", "text":t} }
     }.to_json
    http.request(req)

    Rails.logger.info "[LINE] Broadcasted. book: #{chapter.book_id}, index: #{chapter.index}"
  end
end
