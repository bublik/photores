# == Schema Information
#
# Table name: bcomments
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  blog_id    :integer
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#


class Bcomment < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  
  validates_length_of :body, :minimum => 10
  validates_presence_of :blog_id
  #validates_associated :user
  validates_presence_of :user_id
  
  def after_create
    self.user.update_attribute(:last_activity, "Добавил коментарий в блогах")
  end

end
