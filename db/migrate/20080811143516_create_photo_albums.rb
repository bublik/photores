class CreatePhotoAlbums < ActiveRecord::Migration
  def self.up
    create_table :photo_albums, :force => true do |t|
      t.string :name
      t.boolean :frendly, :default => false
      t.integer :user_id, :null => false
      
      t.timestamps
    end
    create_table :photo_albums_photos, :force => true, :id => false do |t|
      t.integer :photo_id, :null => false
      t.integer :photo_album_id,:null => false

      t.timestamps
    end
    add_index :photo_albums, [:user_id]
    add_index :photo_albums_photos, [:photo_id, :photo_album_id]
  end

  def self.down
    drop_table :photo_albums
    drop_table :photo_albums_photos
  end
end
