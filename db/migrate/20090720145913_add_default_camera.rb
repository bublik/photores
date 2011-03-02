class AddDefaultCamera < ActiveRecord::Migration
  def self.up
    add_column :photo_profiles, :is_default, :boolean, :default => false
  end

  def self.down
    remove_column :photo_profiles, :is_default
  end
end
