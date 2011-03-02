class AddColumnIsModerate < ActiveRecord::Migration
  def self.up
    add_column :photos, :is_moderated, :boolean, :default => true
    Photo.update_all("is_moderated = 'true'")
    add_column :tags, :is_uploadet, :boolean, :default => false
    Tag.update_all("is_uploadet = 'false'")
  end

  def self.down
    remove_column :photos, :is_moderated
    remove_column :tags, :is_uploadet
  end
end
