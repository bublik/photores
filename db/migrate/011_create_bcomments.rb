class CreateBcomments < ActiveRecord::Migration
  def self.up
    create_table :bcomments do |t|
      t.references :user
      t.references :blog
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :bcomments
  end
end
