# == Schema Information
#
# Table name: attachments
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  attachable_id   :integer
#  filename        :string(255)     not null
#  size            :integer         default(0), not null
#  content_type    :string(255)
#  height          :integer
#  width           :integer
#  parent_id       :integer
#  thumbnail       :string(255)
#  attachable_type :string(255)
#

class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  belongs_to :user, :polymorphic => true
  
  belongs_to :wiki, :polymorphic => true
  belongs_to :message, :polymorphic => true
  
  has_attachment :storage => :file_system,
    :path_prefix => 'public/upload',
    :thumbnails => { :thumb => '100x100>' }

  validates_presence_of :filename
  validates_numericality_of :size
  #
  #  def before_create
  #    if self.parent_id
  #      self.user_id = self.parent.user_id
  #      self.message_id = self.parent.message_id
  #    end
  #  end

  def title
    self.filename.split('/')[-1]
  end

  def is_image?
    self.content_type.match('image')
  end
  
  def is_exist_thumb?
    File.exist?(Rails.public_path+self.public_filename(:thumb))
  end
end
