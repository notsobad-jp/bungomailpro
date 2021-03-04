class Feed < ApplicationRecord
  belongs_to :book_assignment
  belongs_to :delayed_job, required: false

  after_destroy do
    self.delayed_job&.delete
  end

  def schedule
    return if self.send_at < Time.current
    res = BungoMailer.with(feed: self).feed_email.deliver_later(queue: 'feed_email', wait_until: self.send_at)
    self.update!(delayed_job_id: res.provider_job_id)
  end

  def send_at
    Time.zone.parse("#{delivery_date.to_s} #{book_assignment.channel.delivery_time}")
  end
end
