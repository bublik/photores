# == Schema Information
#
# Table name: blogs
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class Blog < ActiveRecord::Base
  acts_as_rated(:rating_range => 1..5)
  belongs_to :user
  has_many :bcomments
  acts_as_taggable
  
  validates_presence_of :user_id, :message => 'не может быть анонимным.'
  validates_uniqueness_of :title
  validates_length_of :title, :minimum => 5
  validates_presence_of :body
  named_scope :today, lambda {{:conditions => ['created_at > ?', Time.now.ago(24.hours)]}}
    
  cattr_reader :per_page
  @@per_page = 5
  
  define_index do
    indexes :title, :sortable => true
    indexes :body
    # indexes bcomments.body, :as => :blog_comment
    indexes [user.first_name,user.last_name], :as => :user_name

    #   set_property :delta => true
  end

  def to_param
    "#{self.id}-#{self.title.gsub(/[\W]/,'-')}"
  end

  def created_by?(user)
    self.user_id.eql?(user.id)
  end


  def after_create
    self.user.update_attribute(:last_activity, 'Добавил новую запись в своем блоге')
  end
end
