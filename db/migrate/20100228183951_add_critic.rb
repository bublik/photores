class AddCritic < ActiveRecord::Migration
  def self.up
    add_column :photos, :want_critic, :boolean, :default => true
    Photo.reset_column_information
    Photo.update_all :want_critic => true
  end

  def self.down
    remove_column :photos, :want_critic
  end
end
