# == Schema Information
#
# Table name: wikis
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  title        :string(255)
#  message      :text
#  created_at   :datetime
#  updated_at   :datetime
#  rating_count :integer
#  rating_total :decimal(, )
#  rating_avg   :decimal(10, 2)
#

class Wiki < ActiveRecord::Base
  belongs_to :user
  has_many :attachments, :as => :attachable, :dependent => :destroy

  acts_as_rated(:rating_range => 1..5) #, :rater_class => 'User', :rated_class => 'Message'
  acts_as_taggable #enable tags

  validates_length_of :title, :minimum => 3
  validates_length_of :message, :minimum => 40
  scope :today, lambda {{:conditions => ['created_at > ?', Time.now.ago(24.hours)]}}
  
  @@per_page = 10
  @@total_entries = 15
  cattr_reader :per_page


  def after_create
    self.user.increment!(:posts)
    self.user.update_attribute(:last_activity, 'Написал новую статью')
  end

  def to_param
    "#{self.id}-#{self.title.gsub(/[\W]/,'-')}"
  end

  #  def created_by?(user)
  #    self.user_id.eql?(user.id)
  #  end
end
