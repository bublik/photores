# == Schema Information
#
# Table name: photo_albums
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  frendly    :boolean
#  user_id    :integer         not null
#  created_at :datetime
#  updated_at :datetime
#

class PhotoAlbum < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :photos, :order => 'photos.created_at DESC'
  
  validates_length_of  :name, :in => 3..50
  validates_associated :user
  named_scope :today, lambda {{:conditions => ['created_at > ?', Time.now.ago(24.hours)]}}
  
  def after_create
    self.user.update_attribute(:last_activity, 'Создал фото альбом')
  end
    
  def to_param
    "#{self.id}-#{self.name.gsub(/[\W]/,'-')}"
  end
end
