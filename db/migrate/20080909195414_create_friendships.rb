class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :user_id,  :null => false
      t.integer :friend_id, :null => false
      t.boolean :xfn_friend, :default => false, :null => false
      t.boolean :xfn_acquaintance, :default => false, :null => false
      t.boolean :xfn_contact, :default => false, :null => false
      t.boolean :xfn_met, :default => false, :null => false
      t.boolean :xfn_coworker, :default => false, :null => false
      t.boolean :xfn_colleague, :default => false, :null => false
      t.boolean :xfn_coresident, :default => false, :null => false
      t.boolean :xfn_neighbor, :default => false, :null => false
      t.boolean :xfn_child, :default => false, :null => false
      t.boolean :xfn_parent, :default => false, :null => false
      t.boolean :xfn_sibling, :default => false, :null => false
      t.boolean :xfn_spouse, :default => false, :null => false
      t.boolean :xfn_kin, :default => false, :null => false
      t.boolean :xfn_muse, :default => false, :null => false
      t.boolean :xfn_crush, :default => false, :null => false
      t.boolean :xfn_date, :default => false, :null => false
      t.boolean :xfn_sweetheart, :default => false, :null => false
      t.timestamps
    end
    add_index :friendships, [:user_id, :friend_id]
  end

  def self.down
    drop_table :friendships
  end
end
