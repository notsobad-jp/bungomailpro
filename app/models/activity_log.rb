class ActivityLog < ApplicationRecord
  self.abstract_class = true

  scope :applicable, -> { where("apply_at < ?", Time.current).where(finished: false, canceled: false) }
  scope :scheduled, -> { where("apply_at > ?", Time.current).where(finished: false, canceled: false) }

  def self.apply_all
  end

  def upsert_attributes
  end
end
