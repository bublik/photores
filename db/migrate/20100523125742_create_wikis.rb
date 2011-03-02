class CreateWikis < ActiveRecord::Migration
  def self.up
    create_table :wikis do |t|
      t.integer :user_id
      t.string :title
      t.text :message

      t.timestamps
    end
    Wiki.add_ratings_columns
  end
  
  def self.down
    drop_table :wikis
  end
end
