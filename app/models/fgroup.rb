# == Schema Information
#
# Table name: fgroups
#
#  id         :integer         not null, primary key
#  name       :string(255)     default("new group")
#  is_visible :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Fgroup < ActiveRecord::Base
  has_many :forums
  scope :vissible, :conditions => {:is_visible => true}
  validates_presence_of :name
  
end
