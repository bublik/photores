class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos, :force => true do |t|
      t.string :title
      t.integer :user_id
      t.integer :parent_id
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
      t.string :thumbnail
      t.boolean :registred, :default => false
      t.boolean :auto_approve, :default => true

      t.integer :views, :default => 0
      t.integer :complaint, :default => 0
      t.integer :downloads, :default => 0
      
      t.integer :comments_count, :default => 0

      t.date :comment_at, :default => nil
      t.date :show_at, :default => nil
      t.date :download_at, :default => nil
      
      t.timestamps
    end
    add_index(:photos, [:user_id, :parent_id])
    User.reset_column_information
    add_column :users, :photos_count, :integer, :default => 0 unless User.column_names.include?('photos_count')
  end

  def self.down
    drop_table :photos
    remove_column :users, :photos_count
  end
end
