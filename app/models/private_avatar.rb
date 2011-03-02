# == Schema Information
#
# Table name: private_avatars
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  parent_id    :integer
#  content_type :string(255)
#  filename     :string(255)
#  thumbnail    :string(255)
#  size         :integer
#  width        :integer
#  height       :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class PrivateAvatar < ActiveRecord::Base
  belongs_to :user
  has_attachment :content_type => :image, 
    :storage => :file_system, 
    :min_size => 1.kilobytes,
    :max_size => 10.kilobytes,
#    :resize_to => '320x200>',
    :thumbnails => { :thumb => '100x100!', :crop => '80x80!'},
    :processor => 'Rmagick' #ImageScience, Rmagick, and MiniMagick
  #    * :content_type - The content types that are allowed, which defaults to all content types. Using :image allows all standard image types.
  #    * :min_size - The minimum size allowed, which defaults to 1 byte
  #    * :max_size - The maximum size allowed, which defaults to 1 megabyte
  #    * :size - A range of allowed sizes, which overrides the :min_size and :max_size options
  #    * :resize_to - An array of width/height values, or a geometry string for resizing the image
  #    * :thumbnails - A set of thumbnails to generate, specified by a hash of filename suffixes and resizing options. This option can be omitted if you don't need thumbnails, and you can generate more than one thumbnail simply by adding names and sizes to the hash.
  #    * :thumbnail_class - Sets what class (model) to use for thumbnails, which defaults to the current class (MugShot, in this example). You could, for example, use a different model class with a different set of validations.
  #    * :storage - Sets where the actual image data is stored. Options include :file_system, :db_file, and :s3.
  #    * :processor - Sets what image processor to use. Options include ImageScience, Rmagick, and MiniMagick. By default, it will use whatever you have installed.
  #    * :path_prefix - Path to store the uploaded files, which defaults to public/#{table_name} by default for the filesystem. If you're using the S3 backend, it defaults to just #{table_name}.

  
  #["content_type - can't be blank",
  #"content_type - is not included in the list",
  #"size - can't be blank",
  #"size - is not included in the list",
  #"filename - can't be blank"]

  def validates_as_attachment
    validates_presence_of :size, :content_type, :filename 
    validate              :attachment_attributes_valid?
  end
  
end
