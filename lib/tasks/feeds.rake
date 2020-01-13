namespace :feeds do
  task schedule: :environment do |_task, _args|
    Feed.where(send_at: Date.today, scheduled: false).each do |feed|
      begin
        feed.schedule_email
      rescue => e
        logger.error "[FAILED] feed:#{@feed.id}, error: #{e}"
      end
    end
  end
end
