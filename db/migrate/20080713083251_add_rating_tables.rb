class AddRatingTables < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_ratings_table
    Message.add_ratings_columns
  end

  def self.down
    Message.remove_ratings_columns
    ActiveRecord::Base.drop_ratings_table
  end
end
