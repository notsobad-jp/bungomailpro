Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
Delayed::Worker.sleep_delay = 300
Delayed::Worker.delay_jobs = false if Rails.env.development?
