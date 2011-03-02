class UpdateUser < ActiveRecord::Migration
  def self.up
    change_column :users, :interests, :text
    change_column :users, :job, :text
    change_column :users, :description, :text
  end

  def self.down
  end
end
