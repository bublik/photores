class AddSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions, :force => true do |t|
      t.column :session_id, :string
      t.column :data, :text
      t.column :updated_at, :datetime
    end
    
    add_index :sessions, :session_id
    
    #INITIAL DB

    create_table "users", :force => true do |t|
      t.string    "login",          :limit => 15,                     :null => false
      t.string    "email",          :limit => 50,                     :null => false
      t.string    "first_name",     :limit => 20,                     :null => false
      t.string    "last_name",      :limit => 20,                     :null => false
      t.string    "description",    :default =>''
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
      t.integer   "posts",          :default => 0
      
      t.timestamps
    end

    add_index "users", ["login"], :name => "login", :unique => true
    add_index "users", ["email"], :name => "email", :unique => true
    add_index "users", ["login"], :name => "users_login"
    add_index "users", ["email"], :name => "users_email"
    add_index "users", ["crypt_password"], :name => "users_crypt_password"

    create_table :fgroups, :force => true do |t|
      t.string :name, :default => 'new group'
      t.boolean :is_visible, :default => false

      t.timestamps
    end
    
    create_table "forums", :force => true do |t|
      t.references :fgroup
      t.string    "name",        :limit => 100,                :null => false
      t.string    "description"
      t.integer   "sort",                   :default => 0
      t.integer   "last_msg",                   :default => 0
      t.datetime "updated_at",                  :null => false
      t.integer   "state",                      :default => 0
    end

    create_table "messages", :force => true do |t|
      t.integer   "parent_id"
      t.integer   "user_id",                                    :null => false
      t.integer   "forum_id",                                   :null => false
      t.string    "name",         :limit => 250,                :null => false
      t.text      "message"
      t.integer   "posts",                       :default => 0
      t.integer   "views",                       :default => 0
      t.integer   "openclose",                   :default => 0
      t.integer   "stickunstick",                :default => 0
      t.integer   "icon"
      t.string    "ip",           :limit => 50
      t.integer   "described"

      t.timestamps
    end

    add_index "messages", ["parent_id"], :name => "messag_parent_id"
    add_index "messages", ["user_id"], :name => "messag_user_id"
    add_index "messages", ["forum_id"], :name => "messag_forum_id"
    
    create_table :attachments, :force => true do |t|
      t.integer :user_id,  :null=>false
      t.integer :message_id,   :null=>false
      t.string :filename, :null=>false
      t.integer :filesize, :null=>false, :default => 0
    end

    add_index "attachments", ["user_id", "message_id"], :name => "user_id"

    u = User.new(:login => 'bublik',
      :email => 'rebisall@gmail.com',
      :first_name =>'Ruslan',
      :last_name => 'Voloshin', 
      :password => 'admin',
      :password_confirmation => 'admin',
      :home_page => 'http://fotolife.com.ua',
      :location => 'odessa',
      :icq_number => '207238348',
      :interests => 'php perl sql ruby rails',
      :job => 'Comodo Group'
    )
    u.save
    #Add admin privilegies
    User.grand_admin(u)   

    fg = Fgroup.new(:name => 'Демо раздел', :is_visible => true)
    fg.forums << Forum.new(:name => 'Форум для демо раздела',
      :description => 'Для дальнейшей работы отредактируйте раздел и форум')
    fg.save

  end

  def self.down
    drop_table :sessions
    drop_table :users
    drop_table :fgroups
    drop_table :forums
    drop_table :attachments
    drop_table :messages
  end
end
