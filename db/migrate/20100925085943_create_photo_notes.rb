class CreatePhotoNotes < ActiveRecord::Migration
  def self.up
    create_table :photo_notes do |t|
      t.integer :photo_id
      t.integer :user_id
      t.integer :x1
      t.integer :y1
      t.integer :height
      t.integer :width
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_notes
  end
end
