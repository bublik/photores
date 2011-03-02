class CreatePhotoProfiles < ActiveRecord::Migration
  def self.up
    create_table :photo_profiles do |t|
      t.integer :user_id
      t.integer :camera_brand_id
      t.string :description

      t.timestamps
    end
    add_column :photos, :photo_profile_id, :integer
    add_index :photo_profiles, [:user_id, :camera_brand_id]
  end

  def self.down
    drop_table :photo_profiles
  end
end
