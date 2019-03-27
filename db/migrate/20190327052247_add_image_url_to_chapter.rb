class AddImageUrlToChapter < ActiveRecord::Migration[5.2]
  def change
    add_column :chapters, :image_url, :string
  end
end
