class NullifyDelayedJobsForeignKey < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :chapters, :delayed_jobs
    add_foreign_key :chapters, :delayed_jobs, on_delete: :nullify
  end
end
