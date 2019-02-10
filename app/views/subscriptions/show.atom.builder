atom_feed do |feed|
  feed.title(@subscription.channel.title)
  feed.author('ブンゴウメール')
  feed.updated(@subscription.feeds.first.try(:delivered_at) || @subscription.created_at)

  @subscription.feeds.each do |post|
    feed.entry(post, url: "#{subscription_url(@subscription)}/#{post.book_id}_#{post.index}") do |entry|
      entry.title("#{post.book.title}（#{post.chapter.index}/#{post.book.chapters_count}）")
      entry.content(post.chapter.text)

      entry.author do |author|
        author.name(post.book.author)
      end
    end
  end
end
