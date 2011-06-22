class CreatePhotoCategories < ActiveRecord::Migration
  def self.up
    create_table :photo_categories,:force => true do |t|
      t.string :title
      t.string :identifier
      
      t.timestamps
    end
    
    PhotoCategory.reset_column_information
    YAML.load_file("#{Rails.root}/test/fixtures/photo_categories.yml").each do |k, cat|
      c = PhotoCategory.find_or_create_by_identifier(cat['identifier'])
      c.update_attributes(cat)
    end
    
    
    create_table :photo_categories_photos, :force => true, :id => false do |t|
      t.integer :photo_id, :null => false
      t.integer :photo_category_id, :null => false

      t.timestamps
    end
      add_index :photo_categories_photos, ["photo_id","photo_category_id"]

  end

  def self.down
    drop_table :photo_categories
    drop_table :photo_categories_photos
  end
end
