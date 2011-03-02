class MigrateTuAttachFu < ActiveRecord::Migration
  require 'action_controller'
  require 'action_controller/test_process.rb'

  def self.up
    rename_column :attachments, :filesize, :size
    change_column :attachments, :user_id, :integer, :null => true
    change_column :attachments, :message_id, :integer, :null => true
    
    add_column  :attachments, :content_type, :string   # mime type, ex: application/mp3
    add_column  :attachments, :height,       :integer  # in pixels
    add_column  :attachments, :width,        :integer  # in pixels
    add_column  :attachments, :parent_id,    :integer  # id of parent image (on the same table, a self-referencing foreign-key).
    add_column  :attachments, :thumbnail,    :string   # the 'type' of thumbnail this attachment record describes.

    Attachment.find_each do |f|
      f_path = Rails.public_path+f.filename
      mimetype = `file -ib #{f_path}`.gsub(/\n/,"")

      attach = Attachment.new(f.attributes)
      attach.uploaded_data = ActionController::TestUploadedFile.new(f_path, mimetype)
      attach.save
      f.destroy
    end
    
  end

  def self.down
    rename_column :attachments, :filesize, :size

    remove_column  :attachments, :size
    remove_column  :attachments, :content_type
    remove_column  :attachments, :height
    remove_column  :attachments, :width
    remove_column  :attachments, :parent_id
    remove_column  :attachments, :thumbnail
  end
end
