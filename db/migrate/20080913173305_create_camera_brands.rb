class CreateCameraBrands < ActiveRecord::Migration
  def self.up
    create_table :camera_brands, :force => true do |t|
      t.string :name

      t.timestamps
    end
    
    cam_brands = YAML.load_file('test/fixtures/camera_brands.yml')
    cam_brands.keys.each do |key|
      CameraBrand.create(cam_brands[key])
    end
  end

  def self.down
    drop_table :camera_brands
  end
end
