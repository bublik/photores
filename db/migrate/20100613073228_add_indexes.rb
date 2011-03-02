class AddIndexes < ActiveRecord::Migration
  def self.up
    #existed indexes
    #  add_index "attachment", ["user_id"], :name => "user_id"
    #  add_index "attachment", ["message_id"], :name => "attachment_post_id"
    #  add_index "messages", ["parent_id"], :name => "messag_parent_id"
    #  add_index "messages", ["user_id"], :name => "messag_user_id"
    #  add_index "messages", ["forum_id"], :name => "messag_forum_id"
    #  add_index "users", ["login"], :name => "login", :unique => true
    #  add_index "users", ["email"], :name => "email", :unique => true
    #  add_index "users", ["login"], :name => "users_login"
    #  add_index "users", ["email"], :name => "users_email"
    #  add_index "users", ["crypt_password"], :name => "users_crypt_password"
    #  add_index :friendships, [:user_id, :friend_id]
    #  add_index :histograms, :photo_id
    #  add_index :photo_albums, :user_id
 
    add_index :users, :subdomain
    add_index :contests, [:date_from, :date_to, :is_completed], :name => 'is_completed'
    add_index :photos, :user_id
    add_index :photos, :parent_id
    add_index :photos, :is_moderated

    add_index :photos, :created_at
    add_index :photos, [:downloads, :download_at, :parent_id, :is_moderated], :name => 'last_downloadet'
    add_index :priv_messages, :user_id
   
    add_index :priv_messages, [:read, :to_user_id]
    add_index :private_avatars, :user_id
    add_index :taggings, :tag_id
    add_index :taggings, :taggable_type
    add_index :taggings, :taggable_id
   
    add_index :photo_albums_photos, :photo_id
    add_index :photo_albums_photos, :photo_album_id
    add_index :blogs, :user_id
    add_index :bcomments, :blog_id
    add_index :ratings, [:rated_id, :rated_type]
    add_index :forums, :fgroup_id
    add_index :fgroups, :is_visible
    add_index :messages, [:forum_id, :parent_id, :updated_at]
    add_index :comments, [:commentable_id, :commentable_type, :created_at], :name => 'all_comments'
  end

  def self.down
  end
end
