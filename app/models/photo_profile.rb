# == Schema Information
#
# Table name: photo_profiles
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  camera_brand_id :integer
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  is_default      :boolean
#

class PhotoProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :camera_brand
  has_many :photos
  
  validates_presence_of :description

  def full_description
    "#{self.camera_brand.name} #{self.description}"
  end
  
end
