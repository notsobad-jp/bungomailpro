class Chapter < ApplicationRecord
  belongs_to :book_assignment
  belongs_to :delayed_job, required: false

  after_destroy do
    self.delayed_job&.delete
  end

  def schedule
    return if self.send_at < Time.current
    res = BungoMailer.with(chapter: self).chapter_email.deliver_later(queue: 'chapter_email', wait_until: self.send_at)
    self.update!(delayed_job_id: res.provider_job_id)
  end
end
