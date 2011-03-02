# == Schema Information
#
# Table name: priv_messages
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  to_user_id :integer         not null
#  title      :text            not null
#  data       :text
#  read       :boolean
#  created_at :datetime
#

class PrivMessage < ActiveRecord::Base
  belongs_to :user
  
  validates_format_of :to_user_id, :with => /^[0-9]+$/, :on => :create
 
=begin
      t.column :users_id, :int,:null=>false
      t.column :to_user_id, :int,:null=>false
      t.column :title, :text, :null=>false
      t.column :data, :text,:default=>nil
      t.column :read, :boolean,:default=>false
      t.column :created_at, :timestamp
=end

  def before_create
    #Инициализируем начальные 
    self.created_at=Time.now
  end

end
