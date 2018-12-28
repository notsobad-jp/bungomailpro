namespace :tmp_tasks do
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
end
