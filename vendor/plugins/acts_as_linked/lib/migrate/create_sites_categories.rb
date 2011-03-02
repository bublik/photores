class CreateSitesCategories < ActiveRecord::Migration
  def self.up
    create_table :sites_categories, :force => true do |t|
      t.string :name
      t.string :identifier, :null => false
      t.text :description

      t.timestamps
    end
    
    categories = [
      {:name => 'Разное', :identifier => 'others', :description => 'Все что не вошло ни в один из разделов.'},
      {:name => 'Студии', :identifier => 'photo-studios', :description => 'Каталог фото студий'},
      {:name => 'Магазины', :identifier => 'photo-shops', :description => 'Магазины занимаещиеся продажей фото техники и сопутствующих товаров.'},
      {:name => 'Галереи', :identifier => 'photo-galleries', :description => 'Галереи фотографийи стоковые ресурсы.'},
      {:name => 'Клубы', :identifier => 'photo-clubs', :description => 'Клубы и сообщества фото любителей.'},
      {:name => 'Личные страницы фотографов', :identifier => 'photo-professionals', :description => 'Личные страницы'},
      {:name => 'Блогеры', :identifier => 'photo-blogs', :description => 'Фото блогеры и их ресурсы.'},
      {:name => 'Журналы', :identifier => 'photo-magazines', :description => 'Журналы и издания по фото тематике.'},
      {:name => 'Обработка изображений', :identifier => 'photo-editors', :description => 'Ресурсы по обработке изображений.'},      
    ]
    
    categories.each do |c|
      SitesCategory.create!(c)
    end
  end

  def self.down
    drop_table :sites_categories
  end
end
