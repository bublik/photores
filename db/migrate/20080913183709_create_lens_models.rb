class CreateLensModels < ActiveRecord::Migration
  def self.up
    create_table :lens_models do |t|
      t.integer :camera_brand_id
      t.string :model

      t.timestamps
    end
  end

  def self.down
    drop_table :lens_models
  end
end
