class UpdateAttachement < ActiveRecord::Migration
  def self.up
    add_column(:attachments, :attachable_type, :string)
    rename_column(:attachments, :message_id, :attachable_id)
    Attachment.update_all("attachable_type = 'Message'")
    add_index :attachments, :parent_id
    add_index :attachments, [:attachable_id, :attachable_type]
  end

  def self.down
    remove_column(:attachments, :attachable_type)
    rename_column(:attachments, :attachable_id, :message_id)
  end
end
