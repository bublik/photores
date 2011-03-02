class AddReplayColumn < ActiveRecord::Migration
  
  def self.up
    add_column :messages, :toreplay_id, :integer
  end

  def self.down
    remove_column :messages, :toreplay_id
  end
end
