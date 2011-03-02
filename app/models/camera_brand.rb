# == Schema Information
#
# Table name: camera_brands
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class CameraBrand < ActiveRecord::Base
  has_many :photo_profiles

  validates_uniqueness_of :name
  validates_presence_of :name
  
end
