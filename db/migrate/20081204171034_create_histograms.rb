class CreateHistograms < ActiveRecord::Migration
  def self.up
    create_table :histograms do |t|
      t.references :photo
      t.integer :r, :default => 0
      t.integer :g, :default => 0
      t.integer :b, :default => 0
      t.integer :y, :default => 0
      t.integer :u, :default => 0
      t.integer :v, :default => 0
      t.integer :count, :default => 0
      
      t.timestamps
    end
    add_index(:histograms, :photo_id)
  end

  def self.down
    drop_table :histograms
  end
end
