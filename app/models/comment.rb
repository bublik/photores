# == Schema Information
#
# Table name: comments
#
#  id               :integer         not null, primary key
#  title            :string(50)      default("")
#  comment          :text
#  is_approved      :boolean
#  commentable_id   :integer         default(0), not null
#  commentable_type :string(255)     default(""), not null
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :photo, :foreign_key => 'commentable_id', :counter_cache => true
  
  validates_presence_of :comment
  validates_associated :user
  
  scope :approved, :conditions => {:is_approved => true}#, :order => 'id DESC'
  scope :photo, :conditions => {:commentable_type => 'Photo'}
  scope :ptoday, lambda {{:conditions => ['created_at > ? AND commentable_type = \'Photo\'', Time.now.ago(24.hours)]}}
  
  def before_save
    sanitar = HTML::FullSanitizer.new
    self.comment = sanitar.sanitize(self.comment)
  end

  def after_create
    if self.commentable_type.eql?('Photo')
      self.user.update_attribute(:last_activity, 'Прокоментировал фото')
    end
  end
  
  def self.last_comments(commentable_type = nil, limit = 10)
    find(:all, :conditions => {:commentable_type => commentable_type},
      :include => [:user],
      :order => 'updated_at DESC',
      :limit=> limit)
  end
end
