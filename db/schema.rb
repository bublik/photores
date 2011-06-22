# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100925085943) do

  create_table "attachments", :force => true do |t|
    t.integer "user_id"
    t.string  "filename",                       :null => false
    t.integer "size",            :default => 0, :null => false
    t.integer "attachable_id"
    t.string  "content_type"
    t.integer "height"
    t.integer "width"
    t.integer "parent_id"
    t.string  "thumbnail"
    t.string  "attachable_type"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], :name => "index_attachments_on_attachable_id_and_attachable_type"
  add_index "attachments", ["parent_id"], :name => "index_attachments_on_parent_id"

  create_table "bcomments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "blog_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bcomments", ["blog_id"], :name => "index_bcomments_on_blog_id"

  create_table "blogs", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogs", ["user_id"], :name => "index_blogs_on_user_id"

  create_table "camera_brands", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.boolean  "is_approved",                    :default => false
    t.integer  "commentable_id",                 :default => 0,     :null => false
    t.string   "commentable_type",               :default => "",    :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type", "created_at"], :name => "all_comments"
  add_index "comments", ["user_id", "commentable_id"], :name => "fk_comments_index"

  create_table "contests", :force => true do |t|
    t.string   "title",                           :null => false
    t.text     "description",                     :null => false
    t.string   "prize"
    t.text     "sponsor"
    t.integer  "photo_id"
    t.date     "date_from"
    t.date     "date_to"
    t.boolean  "is_completed", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contests", ["date_from", "date_to", "is_completed"], :name => "is_completed"

  create_table "fgroups", :force => true do |t|
    t.string   "name",       :default => "new group"
    t.boolean  "is_visible", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fgroups", ["is_visible"], :name => "index_fgroups_on_is_visible"

  create_table "forums", :force => true do |t|
    t.integer  "fgroup_id"
    t.string   "name",        :limit => 100,                :null => false
    t.string   "description"
    t.integer  "sort",                       :default => 0
    t.integer  "last_msg",                   :default => 0
    t.datetime "updated_at",                                :null => false
    t.integer  "state",                      :default => 0
  end

  add_index "forums", ["fgroup_id"], :name => "index_forums_on_fgroup_id"

  create_table "friend_sites", :force => true do |t|
    t.integer  "sites_category_id"
    t.string   "url",                                                 :null => false
    t.string   "title",             :limit => 100,                    :null => false
    t.string   "button_url"
    t.string   "description"
    t.string   "admin_email",                                         :null => false
    t.string   "refered_page"
    t.boolean  "is_active",                        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",                             :null => false
    t.integer  "friend_id",                           :null => false
    t.boolean  "xfn_friend",       :default => false, :null => false
    t.boolean  "xfn_acquaintance", :default => false, :null => false
    t.boolean  "xfn_contact",      :default => false, :null => false
    t.boolean  "xfn_met",          :default => false, :null => false
    t.boolean  "xfn_coworker",     :default => false, :null => false
    t.boolean  "xfn_colleague",    :default => false, :null => false
    t.boolean  "xfn_coresident",   :default => false, :null => false
    t.boolean  "xfn_neighbor",     :default => false, :null => false
    t.boolean  "xfn_child",        :default => false, :null => false
    t.boolean  "xfn_parent",       :default => false, :null => false
    t.boolean  "xfn_sibling",      :default => false, :null => false
    t.boolean  "xfn_spouse",       :default => false, :null => false
    t.boolean  "xfn_kin",          :default => false, :null => false
    t.boolean  "xfn_muse",         :default => false, :null => false
    t.boolean  "xfn_crush",        :default => false, :null => false
    t.boolean  "xfn_date",         :default => false, :null => false
    t.boolean  "xfn_sweetheart",   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["user_id", "friend_id"], :name => "index_friendships_on_user_id_and_friend_id"

  create_table "histograms", :force => true do |t|
    t.integer  "photo_id"
    t.integer  "r",          :default => 0
    t.integer  "g",          :default => 0
    t.integer  "b",          :default => 0
    t.integer  "y",          :default => 0
    t.integer  "u",          :default => 0
    t.integer  "v",          :default => 0
    t.integer  "count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "histograms", ["photo_id"], :name => "index_histograms_on_photo_id"

  create_table "lens_models", :force => true do |t|
    t.integer  "camera_brand_id"
    t.string   "model"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "user_id",                                                                   :null => false
    t.integer  "forum_id",                                                                  :null => false
    t.string   "name",         :limit => 250,                                               :null => false
    t.text     "message"
    t.integer  "posts",                                                      :default => 0
    t.integer  "views",                                                      :default => 0
    t.integer  "openclose",                                                  :default => 0
    t.integer  "stickunstick",                                               :default => 0
    t.integer  "icon"
    t.string   "ip",           :limit => 50
    t.integer  "described"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total"
    t.decimal  "rating_avg",                  :precision => 10, :scale => 2
    t.integer  "toreplay_id"
  end

  add_index "messages", ["forum_id", "parent_id", "updated_at"], :name => "index_messages_on_forum_id_and_parent_id_and_updated_at"
  add_index "messages", ["forum_id"], :name => "messag_forum_id"
  add_index "messages", ["parent_id"], :name => "messag_parent_id"
  add_index "messages", ["user_id"], :name => "messag_user_id"

  create_table "photo_albums", :force => true do |t|
    t.string   "name"
    t.boolean  "frendly",    :default => false
    t.integer  "user_id",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photo_albums", ["user_id"], :name => "index_photo_albums_on_user_id"

  create_table "photo_albums_photos", :id => false, :force => true do |t|
    t.integer  "photo_id",       :null => false
    t.integer  "photo_album_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photo_albums_photos", ["photo_album_id"], :name => "index_photo_albums_photos_on_photo_album_id"
  add_index "photo_albums_photos", ["photo_id", "photo_album_id"], :name => "index_photo_albums_photos_on_photo_id_and_photo_album_id"
  add_index "photo_albums_photos", ["photo_id"], :name => "index_photo_albums_photos_on_photo_id"

  create_table "photo_categories", :force => true do |t|
    t.string   "title"
    t.string   "identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_categories_photos", :id => false, :force => true do |t|
    t.integer  "photo_id",          :null => false
    t.integer  "photo_category_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photo_categories_photos", ["photo_id", "photo_category_id"], :name => "index_photo_categories_photos_on_photo_id_and_photo_category_id"

  create_table "photo_notes", :force => true do |t|
    t.integer  "photo_id"
    t.integer  "user_id"
    t.integer  "x1"
    t.integer  "y1"
    t.integer  "height"
    t.integer  "width"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_profiles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "camera_brand_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",      :default => false
  end

  add_index "photo_profiles", ["user_id", "camera_brand_id"], :name => "index_photo_profiles_on_user_id_and_camera_brand_id"

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.string   "thumbnail"
    t.boolean  "registred",                                        :default => false
    t.boolean  "auto_approve",                                     :default => true
    t.integer  "views",                                            :default => 0
    t.integer  "complaint",                                        :default => 0
    t.integer  "downloads",                                        :default => 0
    t.integer  "comments_count",                                   :default => 0
    t.date     "comment_at"
    t.date     "show_at"
    t.date     "download_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_profile_id"
    t.integer  "contest_id"
    t.boolean  "is_moderated",                                     :default => true
    t.text     "exif"
    t.boolean  "want_critic",                                      :default => true
    t.decimal  "lat",              :precision => 15, :scale => 10
    t.decimal  "lng",              :precision => 15, :scale => 10
  end

  add_index "photos", ["contest_id"], :name => "index_photos_on_contest_id"
  add_index "photos", ["created_at"], :name => "index_photos_on_created_at"
  add_index "photos", ["downloads", "download_at", "parent_id", "is_moderated"], :name => "last_downloadet"
  add_index "photos", ["is_moderated"], :name => "index_photos_on_is_moderated"
  add_index "photos", ["lat", "lng"], :name => "index_photos_on_lat_and_lng"
  add_index "photos", ["parent_id"], :name => "index_photos_on_parent_id"
  add_index "photos", ["user_id", "parent_id"], :name => "index_photos_on_user_id_and_parent_id"
  add_index "photos", ["user_id"], :name => "index_photos_on_user_id"

  create_table "priv_messages", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "to_user_id",                    :null => false
    t.text     "title",                         :null => false
    t.text     "data"
    t.boolean  "read",       :default => false
    t.datetime "created_at"
  end

  add_index "priv_messages", ["read", "to_user_id"], :name => "index_priv_messages_on_read_and_to_user_id"
  add_index "priv_messages", ["to_user_id"], :name => "index_priv_messages_on_to_user_id"
  add_index "priv_messages", ["user_id"], :name => "index_priv_messages_on_user_id"

  create_table "private_avatars", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "private_avatars", ["user_id"], :name => "index_private_avatars_on_user_id"

  create_table "ratings", :force => true do |t|
    t.integer "rater_id"
    t.integer "rated_id"
    t.string  "rated_type"
    t.decimal "rating"
  end

  add_index "ratings", ["rated_id", "rated_type"], :name => "index_ratings_on_rated_id_and_rated_type"
  add_index "ratings", ["rated_type", "rated_id"], :name => "index_ratings_on_rated_type_and_rated_id"
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites_categories", :force => true do |t|
    t.string   "name"
    t.string   "identifier",  :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"
  add_index "taggings", ["taggable_type"], :name => "index_taggings_on_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.boolean "is_uploadet", :default => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "users", :force => true do |t|
    t.string   "login",            :limit => 15,                     :null => false
    t.string   "email",            :limit => 50,                     :null => false
    t.string   "first_name",       :limit => 20,                     :null => false
    t.string   "last_name",        :limit => 20,                     :null => false
    t.text     "description",                     :default => ""
    t.string   "avatar",           :limit => 50,                     :null => false
    t.integer  "privilegies",                     :default => 2
    t.integer  "raiting",                         :default => 0
    t.string   "password",         :limit => 32,                     :null => false
    t.string   "crypt_password",   :limit => 32,                     :null => false
    t.boolean  "active",                          :default => false
    t.string   "code_activate",    :limit => 32
    t.datetime "birth_day",                                          :null => false
    t.integer  "icq_number"
    t.string   "skype_name",       :limit => 50
    t.string   "aim_name",         :limit => 50
    t.string   "yahoo_handle",     :limit => 50
    t.string   "msn_handle",       :limit => 50
    t.string   "home_page",        :limit => 100
    t.string   "location",         :limit => 100
    t.text     "interests"
    t.text     "job"
    t.integer  "posts",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photos_count",                    :default => 0
    t.string   "last_activity"
    t.datetime "last_activity_at"
    t.boolean  "subscribed",                      :default => true,  :null => false
    t.string   "subdomain",        :limit => 25
    t.text     "promo"
    t.string   "blog_title"
  end

  add_index "users", ["crypt_password"], :name => "users_crypt_password"
  add_index "users", ["email"], :name => "email", :unique => true
  add_index "users", ["email"], :name => "users_email"
  add_index "users", ["login"], :name => "login", :unique => true
  add_index "users", ["login"], :name => "users_login"
  add_index "users", ["subdomain"], :name => "index_users_on_subdomain"

  create_table "wikis", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_count"
    t.decimal  "rating_total"
    t.decimal  "rating_avg",   :precision => 10, :scale => 2
  end

end
