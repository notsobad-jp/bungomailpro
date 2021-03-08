Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
Delayed::Worker.sleep_delay = 300

if Rails.env.development?
  Delayed::Worker.delay_jobs = ->(job) {
    job.queue == 'feed_email' # 開発環境ではfeedの予約配信のみ遅延実行
  }
end
