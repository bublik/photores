# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "attachment", :force => true do |t|
    t.integer "user_id",                                  :null => false
    t.integer "message_id",                               :null => false
    t.string  "filename",   :limit => 100,                :null => false
    t.integer "filesize",                  :default => 0, :null => false
  end

  add_index "attachment", ["user_id"], :name => "user_id"
  add_index "attachment", ["message_id"], :name => "attachment_post_id"

  create_table "forums", :force => true do |t|
    t.string    "name",        :limit => 100,                :null => false
    t.string    "description"
    t.integer   "sort"
    t.integer   "last_msg",                   :default => 0
    t.timestamp "last_date",                                 :null => false
    t.integer   "themes",                     :default => 0
    t.integer   "posts",                      :default => 0
    t.integer   "state",                      :default => 0
  end

  create_table "messages", :force => true do |t|
    t.integer   "parent_id"
    t.integer   "user_id",                                    :null => false
    t.integer   "forum_id",                                   :null => false
    t.string    "name",         :limit => 250,                :null => false
    t.text      "message"
    t.timestamp "post_date",                                  :null => false
    t.timestamp "update_date",                                :null => false
    t.integer   "posts",                       :default => 0
    t.integer   "views",                       :default => 0
    t.integer   "openclose",                   :default => 0
    t.integer   "stickunstick",                :default => 0
    t.integer   "icon"
    t.string    "ip",           :limit => 50
    t.integer   "described"
  end

  add_index "messages", ["parent_id"], :name => "messag_parent_id"
  add_index "messages", ["user_id"], :name => "messag_user_id"
  add_index "messages", ["forum_id"], :name => "messag_forum_id"

  create_table "users", :force => true do |t|
    t.string    "login",          :limit => 15,                     :null => false
    t.string    "email",          :limit => 50,                     :null => false
    t.string    "first_name",     :limit => 20,                     :null => false
    t.string    "last_name",      :limit => 20,                     :null => false
    t.string    "avatar",         :limit => 50,                     :null => false
    t.integer   "privilegies",                   :default => 2
    t.integer   "raiting",                       :default => 0
    t.string    "password",       :limit => 32,                     :null => false
    t.string    "crypt_password", :limit => 32,                     :null => false
    t.boolean   "active",                        :default => false
    t.string    "code_activate",  :limit => 32
    t.timestamp "birth_day",                                        :null => false
    t.integer   "icq_number"
    t.string    "skype_name",     :limit => 50
    t.string    "aim_name",       :limit => 50
    t.string    "yahoo_handle",   :limit => 50
    t.string    "msn_handle",     :limit => 50
    t.string    "home_page",      :limit => 100
    t.string    "location",       :limit => 100
    t.string    "interests",      :limit => 100
    t.string    "job",            :limit => 100
    t.timestamp "reg_date",                                         :null => false
    t.timestamp "last_visit",                                       :null => false
    t.integer   "posts",                         :default => 0
  end

  add_index "users", ["login"], :name => "login", :unique => true
  add_index "users", ["email"], :name => "email", :unique => true
  add_index "users", ["login"], :name => "users_login"
  add_index "users", ["email"], :name => "users_email"
  add_index "users", ["crypt_password"], :name => "users_crypt_password"

end
