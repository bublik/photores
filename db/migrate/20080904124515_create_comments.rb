class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :title, :limit => 50, :default => ""
      t.text :comment
      t.boolean :is_approved, :default => false
      t.integer :commentable_id, :default => 0, :null => false
      t.string :commentable_type, :default => "", :null => false #:limit => 15
      t.integer :user_id

      t.timestamps
    end

    add_index 'comments', ['user_id','commentable_id'], :name => "fk_comments_index"

  end

  def self.down
    drop_table :comments
  end
end
