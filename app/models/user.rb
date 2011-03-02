# == Schema Information
#
# Table name: users
#
#  id               :integer         not null, primary key
#  login            :string(15)      not null
#  email            :string(50)      not null
#  first_name       :string(20)      not null
#  last_name        :string(20)      not null
#  description      :text            default("")
#  avatar           :string(50)      not null
#  privilegies      :integer         default(2)
#  raiting          :integer         default(0)
#  password         :string(32)      not null
#  crypt_password   :string(32)      not null
#  active           :boolean
#  code_activate    :string(32)
#  birth_day        :datetime        not null
#  icq_number       :integer
#  skype_name       :string(50)
#  aim_name         :string(50)
#  yahoo_handle     :string(50)
#  msn_handle       :string(50)
#  home_page        :string(100)
#  location         :string(100)
#  interests        :text
#  job              :text
#  posts            :integer         default(0)
#  created_at       :datetime
#  updated_at       :datetime
#  photos_count     :integer         default(0)
#  last_activity    :string(255)
#  last_activity_at :datetime
#  subscribed       :boolean         default(TRUE), not null
#  subdomain        :string(25)
#  promo            :text
#  blog_title       :string(255)
#

require 'digest/md5'

class User < ActiveRecord::Base
  attr_protected :privilegies

  has_many :messages
  has_many :priv_messages #send messages
  has_many :get_priv_messages, :class_name => 'PrivMessage',  :foreign_key => 'to_user_id', :order  => 'id DESC'
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_one  :private_avatar
  has_many :blogs
  has_many :bcomments
  has_many :photos
  has_many :photo_profiles
  has_many :photo_albums, :order => 'name'
  has_many :photo_notes
  
  has_many :friendships
  has_many :friends, :through => :friendships, :class_name => 'User'

  apply_simple_captcha :message => " не верный."
  validates_confirmation_of :email, :password
  validates_length_of :password, :in => 4..31
  validates_length_of :login, :in => 4..15
  validates_exclusion_of :login, :in => %w( admin administrator superuser www root pop mail ), :message => ' использовать запрещено.', :if => :new_record?
  validates_uniqueness_of :login, :if => :new_record?
  validates_uniqueness_of :email, :if => :new_record?
  validates_format_of :email, :with => /^(.+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'имеет не верный формат'
  validates_format_of :login, :with => /^[-a-z0-9_]+$/i, :message=> 'состоит из запрешенных символов, разрешенные символы(a-z и 0-9)'

  validates_length_of :home_page, :maximum => 100, :allow_nil => true
  validates_length_of :location, :maximum => 100, :allow_nil => true

  named_scope :active, :conditions => 'active = true', :order => 'id ASC'
  named_scope :random,  :conditions => 'active = true',:order => 'random()'
  named_scope :today, lambda {{:conditions => ['created_at > ?', Time.now.ago(24.hours)]}}
  
  cattr_reader :per_page
  @@per_page = 10
  @@default_avatar = '/images/avatars/noimg.gif'

  def self.grand_admin(user)
    user.privilegies = 1
    user.active = true
    user.save
  end

=begin
Update subdomain for stupid users
=end
  def self.update_subdomains
    self.find_each do |user|
      user.save
    end
  end

  def activate!
    self.update_attribute(:active, true)
  end
  
  def before_create
    #Инициализируем начальные установки пользователя
    self.avatar = @@default_avatar
    self.privilegies = 3
    self.crypt_password = User.md5(self.password)
    self.birth_day = Time.now
    self.first_name = ''
    self.last_name = ''
    self.active = false
    self.code_activate = User.md5(Time.now.to_s)
  end
  
  def before_save
    if self.subdomain.blank?
      self.subdomain = self.login
    elsif self.subdomain.match(/http:\/\/([a-z0-9]+)\..*/i)
      self.subdomain = self.subdomain.match(/http:\/\/([a-z0-9]+)\..*/i)[1]
    end
    self.subdomain.downcase!
    
    self.last_activity_at = Time.now if self.attributes.include?('last_activity_at')
    self.avatar = @@default_avatar if self.avatar.blank?
  end
  
  def full_name
    str = "#{self.first_name} #{self.last_name}"
    str.blank? ? self.login : str
  end

  def new_priv_messages
    self.get_priv_messages.count(:conditions => {:read => false})
  end
  
  def to_param
    "#{self.id}-#{self.full_name.gsub(/[\W]/,'-')}"
  end
  
  alias_method(:to_s, :to_param)

  def to_xml(user = nil)
    is_guest = true if user && user.id.eql?(self.id)
    resp_attr = attributes.dup
    resp_attr.delete('crypt_password')
    resp_attr.delete('password')
    resp_attr.delete('code_activate') unless is_guest
    resp_attr.delete('email') unless is_guest
    resp_attr.to_xml(:root => 'user', :skip_types => true)
  end
  
  def public_avatar
    (self.private_avatar.nil? || self.private_avatar.filename.nil?) ? self.avatar : self.private_avatar.public_filename(:crop)
  end

  
  def self.activity(limit = '10')
    #TODO migrato to named_scope
    find(:all, :conditions => ['last_activity != ?', ''], :order => 'last_activity_at DESC', :limit => limit)
  end

  def is_admin_or_moderator?
    self.privilegies < 3
  end

  def random_photos(limit = 5)
    photos.find(:all, :limit => limit, :order => 'random()')
  end

  private
  def self.md5(password)
    Digest::MD5.hexdigest(password)
  end

  def self.auth(login, password)
    self.find(:first, :conditions => ["login = ? AND crypt_password = ?", login, md5(password)])
  end

end
