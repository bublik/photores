# == Schema Information
#
# Table name: photo_categories
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  identifier :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class PhotoCategory < ActiveRecord::Base
  validates_presence_of :identifier, :if => :new_record?
  validates_uniqueness_of :identifier, :if => :new_record?
  validates_presence_of :title, :if => :new_record?
  
  has_and_belongs_to_many :photos, :order => 'photos.created_at DESC'
  
  def self.all
    find(:all, :order => 'title ASC')
  end
  
  def to_param
    "#{self.id}-#{self.title.gsub(/[\W]/,'-')}"
  end
  
end
