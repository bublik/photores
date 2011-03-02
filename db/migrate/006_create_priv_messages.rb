class CreatePrivMessages < ActiveRecord::Migration
  def self.up
    extend MigrationHelpers #загружаем модуль
#    drop_table :priv_messages
    create_table :priv_messages, :force => true  do |t|
      t.column :user_id, :int,:null=>false
      t.column :to_user_id, :int,:null=>false
      t.column :title, :text, :null=>false
      t.column :data, :text,:default=>nil
      t.column :read, :boolean,:default=>false
      t.column :created_at, :timestamp
    end
    add_index :priv_messages, :to_user_id
 #   foreign_key :priv_messages,:users_id, :users
  end
  
  def self.down
    drop_table :priv_messages
  end
end
