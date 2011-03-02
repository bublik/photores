#t.string :name
#t.string :identifier, :null => false
#t.text :description

class SitesCategory < ActiveRecord::Base
  has_many :friend_sites
  
  validates_uniqueness_of :identifier
  validates_presence_of :name

  def to_param
    "#{self.id}-#{self.name.gsub(/[\W]/,'-')}"
  end
end
