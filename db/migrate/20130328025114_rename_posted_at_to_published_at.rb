class RenamePostedAtToPublishedAt < ActiveRecord::Migration
  def change
    rename_column :posts, :posted_at, :published_at
  end
end
