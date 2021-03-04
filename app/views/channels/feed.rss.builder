xml.instruct! :xml, :version => "1.0"
xml.rss(
  "version" => "2.0",
  "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
  "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
  "xmlns:atom" => "http://www.w3.org/2005/Atom",
  "xmlns:sy" => "http://purl.org/rss/1.0/modules/syndication/",
  "xmlns:slash" => "http://purl.org/rss/1.0/modules/slash/"
) do
  xml.channel do
    xml.title @channel.title
    xml.description @channel.description
    xml.link channel_url(@channel.code || @channel.id)
    xml.language "ja-ja"
    xml.ttl "40"
    xml.pubDate(Time.current.rfc822)
    xml.atom :link, "href" => channel_url(@channel.code || @channel.id), "rel" => "self", "type" => "application/rss+xml"
    @posts.each do |p|
      xml.item do
        xml.title p.title #タイトル
        xml.description do
          xml.cdata! p.content
        end
        xml.pubDate p.send_at.rfc822 #公開日
        xml.guid "#{channel_url(@channel.code || @channel.id)}/chapters/#{p.id}"
        xml.link feed_channel_url(@channel.code || @channel.id)
      end
    end
  end
end
