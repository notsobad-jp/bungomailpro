class Line
  LINE_BASE_URL = 'https://api.line.me/v2/bot/message/broadcast'

  def self.broadcast(subscription)
    uri = URI.parse(LINE_BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    headers = {
      'Authorization'=>"Bearer { #{ENV['LINE_CHANNEL_TOKEN']} }",
      'Content-Type' =>'application/json',
    }
    req = Net::HTTP::Post.new(uri.path, headers)

    text = "#{subscription.current_book.author.tr(',', '、')}『#{subscription.current_book.title}』（#{subscription.next_chapter.index}/#{subscription.current_book.chapters_count}）"
    text += "\r\n-----------------\r\n"
    text += subscription.next_chapter.text
    contents = text.each_char.each_slice(500).map(&:join)
    contents.each_with_index do |content, index|
      contents[index] = index==0 ? content + '…' : '…' + content
    end if contents.count > 1

    req.body = {
      "messages": contents.map{ |t| {"type":"text", "text":t} }
     }.to_json
    http.request(req)

    Rails.logger.info "[LINE] Broadcasted. sub: #{subscription.id}, chapter: #{subscription.next_chapter_index}"
  end
end
