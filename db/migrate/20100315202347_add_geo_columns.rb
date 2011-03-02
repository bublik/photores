class AddGeoColumns < ActiveRecord::Migration
  def self.up
    add_column(:photos, :lat, :decimal, :precision => 15, :scale => 10)
    add_column(:photos, :lng, :decimal, :precision => 15, :scale => 10)
    add_index(:photos, [:lat, :lng])
  end

  def self.down
    remove_columns(:photos, :lat, :lng)
    remove_index(:photos, [:lat, :lng])
  end
end
