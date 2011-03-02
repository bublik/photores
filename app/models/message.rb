# == Schema Information
#
# Table name: messages
#
#  id           :integer         not null, primary key
#  parent_id    :integer
#  user_id      :integer         not null
#  forum_id     :integer         not null
#  name         :string(250)     not null
#  message      :text
#  posts        :integer         default(0)
#  views        :integer         default(0)
#  openclose    :integer         default(0)
#  stickunstick :integer         default(0)
#  icon         :integer
#  ip           :string(50)
#  described    :integer
#  created_at   :datetime
#  updated_at   :datetime
#  rating_count :integer
#  rating_total :decimal(, )
#  rating_avg   :decimal(10, 2)
#  toreplay_id  :integer
#

class Message < ActiveRecord::Base
  acts_as_rated(:rating_range => 1..5) #, :rater_class => 'User', :rated_class => 'Message'
  acts_as_taggable #enable tags
  @@per_page = 10
  @@total_entries = 15
  cattr_reader :per_page
  
  belongs_to :forum
  belongs_to :user
  belongs_to :parent, :class_name => "Message", :foreign_key => "parent_id" 
  has_many :replays, :class_name => "Message",  :foreign_key => "parent_id", :include => [:user, :attachments, :tags], :order  => 'id ASC', :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy

  named_scope :describers, lambda{ |p_id| {:conditions => ['described = 1 AND ? IN (id,parent_id)', p_id]}}
  named_scope :topics, :conditions => "parent_id is null"
  named_scope :today, lambda {{:conditions => ['created_at > ?', Time.now.ago(24.hours)]}}
  
  validates_length_of :name, :minimum => 3, :if => Proc.new { |msg| msg.parent_id.nil? }
  validates_length_of :message, :minimum => 4

  define_index do
    indexes :name, :sortable => true
    indexes :message
    indexes [user.first_name,user.last_name], :as => :user_name
  
    #    set_property :delta => true
  end

  def before_validation
    self.name = '' if self.name.nil?
  end
  def after_create
    self.user.increment!(:posts)
    unless self.parent.nil?
      self.parent.increment!(:posts)
    end
    self.user.update_attribute(:last_activity, 'Написал новое сообщение на форуме')
  end
  
  def after_destroy
    #down posts for message owner
    unless self.parent.nil?
      #Удаляем ответ
      self.user.decrement!(:posts)
      self.parent.decrement!(:posts)
    end
  end
  
  def to_param
    "#{self.id}-#{self.name.gsub(/[\W]/,'-')}"
  end

  def parent?
    self.parent_id.nil?
  end
  
  def created_by?(user)
    self.user_id.eql?(user.id)
  end

  def is_replay?
    !self.toreplay_id.nil?
  end

  def replay_to_user
    User.find(self.toreplay_id)
  end
end
