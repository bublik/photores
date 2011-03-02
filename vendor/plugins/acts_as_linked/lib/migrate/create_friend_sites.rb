class CreateFriendSites < ActiveRecord::Migration
  def self.up
    create_table :friend_sites do |t|
      t.references :sites_category
      t.string :url, :null => false
      t.string :title, :limit => 100, :null => false
      t.string :button_url, :null => true
      t.string :description, :default => nil
      t.string :admin_email, :null => false
      t.string :refered_page, :default => nil
      t.boolean :is_active, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :friend_sites
  end
end
