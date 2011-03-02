class AddBlogColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :subdomain, :string, :limit => 25
    add_column :users, :promo, :text
    add_column :users, :blog_title, :string

    User.reset_column_information
    User.find_each(:batch_size => 100) do |user|
      user.update_attributes({
          :blog_title => "Персональный блог #{user.full_name}",
          :subdomain => user.login,
          :promo => 'Краткая информация о себе, или контактные данные.'
        })
    end

    
  end

  def self.down
    remove_column :users, :subdomain
    remove_column :users, :promo
    remove_column :users, :blog_title
  end
end
