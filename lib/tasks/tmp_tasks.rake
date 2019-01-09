namespace :tmp_tasks do
  # channel_bookのindexを配信後も保持するようにした対応
  task :reset_index => :environment do |task, args|
    Channel.all.each do |channel|
      # 重複しないように、すでにindexがある未配信作品のindexを100ずらす
      channel.channel_books.where(delivered: false).each do |cb|
        cb.update!(index: cb.index + 100)
      end

      # 配信済み（index: nil）の作品をupdated昇順でindexを1から振り直す
      channel.channel_books.where(delivered: true).order(:updated_at).each.with_index(1) do |cb, index|
        cb.update!(index: index)
      end

      # 未配信作品を続きからindex振り直す
      current_index = channel.channel_books.where(delivered: true).maximum(:index) || 0
      channel.channel_books.where(delivered: false).each.with_index(current_index + 1) do |cb, index|
        cb.update!(index: index)
      end
    end
  end


  # delivery情報をchannelsからsubscriptionsに移す対応
  task :subscriptionize => :environment do |task, args|
    Channel.all.each do |channel|
      next_deliver_at = Time.zone.tomorrow if channel.next_chapter_id
      sub = channel.subscriptions.first
      sub.update!(
        next_chapter_id: channel.next_chapter_id,
        last_chapter_id: channel.last_chapter_id,
        delivery_hour: channel.deliver_at,
        next_deliver_at: next_deliver_at
      )
    end
  end


  # ChannelからSubscriptionにデータ移行
  task :migration => :environment do |task, args|
    Channel.all.each do |channel|
      sub = channel.subscriptions.first
      next_chapter = Chapter.find_by(id: channel.next_chapter_id)

      next_delivery_date = Time.zone.tomorrow  if next_chapter
      sub.update!(
        current_book_id: next_chapter.try(:book_id),
        next_chapter_index: next_chapter.try(:index),
        delivery_hour: channel.deliver_at,
        next_delivery_date: next_delivery_date
      )

      channel.update!(
        default: sub.default
      )
    end
  end


  task :timestamp => :environment do |task, args|
    Subscription.all.each do |s|
      s.update!(
        new_created_at: s.created_at,
        new_updated_at: s.updated_at
      )
    end
  end
end
