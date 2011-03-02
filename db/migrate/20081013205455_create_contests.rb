class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests , :force => true do |t|
      t.string :title, :null => false
      t.text :description, :null => false
      t.string :prize
      t.text :sponsor
      t.integer :photo_id, :default => nil
      t.date :date_from
      t.date :date_to
      t.boolean :is_completed, :default => false

      t.timestamps
    end
    
    Contest.create!(
      :title => 'С именинами нас!',
      :description => 'Конкурс продлится всего одну неделю, после выхода новой версии сайта.
      На фотографиях учавствующих в конкурсе должен быть изображен ПРАЗДНИЧНЫЙ ТОРТ которым Вы нас поздравляете.',
      :prize => '1Gb флеш карточка для фотика (тип карты победитель выбирает сам)',
      :date_from => Time.now - 1.day, :date_to => Time.now + 7.days)
    add_column(:photos, :contest_id, :integer, :default => nil)
    add_index(:photos, :contest_id)

  end

  def self.down
    drop_table :contests
    remove_column(:photos, :contest_id)
  end
end
