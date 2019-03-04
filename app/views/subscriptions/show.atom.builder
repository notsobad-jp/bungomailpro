atom_feed do |feed|
  feed.title(@subscription.channel.title)
  feed.author('ブンゴウメール')
  feed.updated(@subscription.feeds.first.try(:delivered_at) || @subscription.created_at)

  @subscription.feeds.each do |post|
    feed.entry(post, id: "#{@subscription.id}_#{post.book_id}-#{post.index}", url: channel_url(@subscription.channel)) do |entry|
      entry.title("#{post.book.title}（#{post.chapter.index}/#{post.book.chapters_count}）")
      entry.content(post.chapter.text)

      entry.author do |author|
        author.name(post.book.author)
      end
    end
  end
end
