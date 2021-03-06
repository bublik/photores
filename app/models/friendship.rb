# == Schema Information
#
# Table name: friendships
#
#  id               :integer         not null, primary key
#  user_id          :integer         not null
#  friend_id        :integer         not null
#  xfn_friend       :boolean         not null
#  xfn_acquaintance :boolean         not null
#  xfn_contact      :boolean         not null
#  xfn_met          :boolean         not null
#  xfn_coworker     :boolean         not null
#  xfn_colleague    :boolean         not null
#  xfn_coresident   :boolean         not null
#  xfn_neighbor     :boolean         not null
#  xfn_child        :boolean         not null
#  xfn_parent       :boolean         not null
#  xfn_sibling      :boolean         not null
#  xfn_spouse       :boolean         not null
#  xfn_kin          :boolean         not null
#  xfn_muse         :boolean         not null
#  xfn_crush        :boolean         not null
#  xfn_date         :boolean         not null
#  xfn_sweetheart   :boolean         not null
#  created_at       :datetime
#  updated_at       :datetime
#

class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User', :foreign_key => 'friend_id'
  validates_presence_of :user_id, :friend_id
  
  def xfn_friendship=(friendship_type)
    self.xfn_friend = false
    self.xfn_acquaintance = false
    self.xfn_contact = false
    case friendship_type
    when 'xfn_friend' : self.xfn_friend = true
    when 'xfn_acquaintance' : self.xfn_acquaintance = true
    when 'xfn_contact' : self.xfn_contact = true
    end
  end
  
  def xfn_friendship
    return 'xfn_friend' if self.xfn_friend == true
    return 'xfn_acquaintance' if self.xfn_acquaintance == true
    return 'xfn_contact' if self.xfn_contact == true
    false
  end
 
  def xfn_geographical=(geo_type)
    self.xfn_coresident = false
    self.xfn_neighbor = false
    case geo_type
    when 'xfn_coresident' : self.xfn_coresident = true
    when 'xfn_neighbor' : self.xfn_neighbor = true
    end
  end
 
  def xfn_geographical
    return 'xfn_coresident' if self.xfn_coresident
    return 'xfn_neighbor' if self.xfn_neighbor
    false
  end
  
  def xfn_family=(family_type)
    self.xfn_child = false
    self.xfn_parent = false
    self.xfn_sibling = false
    self.xfn_spouse = false
    self.xfn_kin = false
    case family_type
    when 'xfn_child' : self.xfn_child = true
    when 'xfn_parent' : self.xfn_parent = true
    when 'xfn_sibling' : self.xfn_sibling = true
    when 'xfn_spouse' : self.xfn_spouse = true
    when 'xfn_kin' : self.xfn_kin = true
    end
  end
  
  def xfn_family
    return 'xfn_child' if self.xfn_child
    return 'xfn_parent' if self.xfn_parent
    return 'xfn_sibling' if self.xfn_sibling
    return 'xfn_spouse' if self.xfn_spouse
    return 'xfn_kin' if self.xfn_kin
    false
  end
end
