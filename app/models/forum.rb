# == Schema Information
#
# Table name: forums
#
#  id          :integer         not null, primary key
#  fgroup_id   :integer
#  name        :string(100)     not null
#  description :string(255)
#  sort        :integer         default(0)
#  last_msg    :integer         default(0)
#  updated_at  :datetime        not null
#  state       :integer         default(0)
#

class Forum < ActiveRecord::Base
  cattr_reader :per_page
  belongs_to :fgroup
  has_many :messages
  
  has_many :themes, :class_name => 'Message', :conditions => ['parent_id IS NULL']
  has_many :posts, :class_name => 'Message', :conditions => ['parent_id IS NOT NULL']
  has_one :lastmsg, :class_name => 'Message', :conditions => ['parent_id IS NULL'], :order => 'updated_at DESC'
  
  validates_presence_of :name

  @@per_page = 30  
=begin
Forum.split(from_id = nil,to_id = nil)
Объединение двух разделов форума в один
при этом from - раздел удаляется
=end
  def split_forums(to_id = nil)
    to = Forum.find_by_id(to_id)
    return unless to
    Message.update_all("forum_id = #{to.id}", ['forum_id = ?',self.id])
    #to.update_attributes(:themes => to.themes.count, :posts => to.posts.count)
    self.destroy
    true
  end
  
end
