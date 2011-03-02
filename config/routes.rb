ActionController::Routing::Routes.draw do |map|
  map.resources :wikis

  Jammit::Routes.draw(map)

  map.resources :priv_messages
  map.resources :contests
  map.resources :photo_profiles
  map.resources :camera_brands
  map.resources :attachments
  map.resources :users
  map.resources :bcomments

  map.forum_list '/forums/list', :controller => 'forums', :action=>'list'

  map.messages_rss '/messages/rss', :controller => 'messages', :action => 'rss'
  map.resources :messages, :member => {:replay => :any }, :collection => {:list => :get, :last_posts => :get}
  map.rate_message '/messages/:id/rate/:rate', :controller => 'messages', :action => 'rate'
  map.tagging '/messages/tag/*tag_name', :controller => 'messages',:action => 'tag'
  map.wiki_tag '/wiki/tag/*tag_name', :controller => 'wikis',:action => 'tag'
  map.user_messages '/user/:id/messages', :controller => 'messages', :action => 'user_msg_list'
  map.user_votes '/user/:id/votes', :controller => 'messages', :action => 'user_vote_list'
  map.user_widget '/user/:id/widget', :controller => 'users', :action => 'widget'
    
  map.resources :photos, :member => {:download => :any, :complaint => :any}, :collection => { :colors => :any }
  map.resources :photo_albums
  map.resources :photo_categories
  map.resources :blogs
  map.resources :fgroups
  map.login '/login', :controller => 'login', :action => 'login'
  map.logout '/logout', :controller => 'login', :action => 'logout'
  map.mobile '/mobile_payment', :controller => 'progect', :action => 'mobile'

  map.resources :users do |user|
    user.resources :blogs
    user.resources :photo_albums
    user.resources :friends
  end
  map.search '/search/*word', :controller => 'finder', :action => 'find'
  map.resources :blogs, :has_many => :bcomments
  map.blogtag '/blogs/tag/*id', :controller => 'blogs', :action => 'tag'
  map.rate_blog '/blogs/:id/rate/:rate', :controller => 'blogs', :action => 'rate'
  map.user_root '', :controller => 'users', :action => 'show', :conditions => { :subdomain => /.+/ }
  map.root :controller => "photos", :action => 'index'


  map.resources :sites_categories, :has_many => :friend_sites
  map.friend_site_activate '/friend_sites_activation/:id/:state', :controller => 'friend_sites', :action => 'activation'
  map.friend_site_remote_validation '/friend_sites_validation/:id', :controller => 'friend_sites', :action => 'remote_validation'
  
  map.progect '/project/:action', :controller => 'progect'
  map.rate_photo '/photos/:id/rate/:rate', :controller => 'photos', :action => 'rate'
  map.photo_row '/photo_row/:id', :controller => 'photos', :action => 'photo_row'
  map.show_notes '/photo_notes/:id.:format', :controller => 'photos', :action => 'show_notes'
  map.add_note '/photo_notes/add/:id', :controller => 'photos', :action => 'add_note'
  map.photo_rotate '/photo_rotate/:id/:to/*page', :controller => 'photos', :action => 'rotate'
  map.photo_tag '/photos/tag/*tag_name', :controller => 'photos', :action => 'tag'
  map.photo_comment '/photos/add_comment/:id', :controller => 'photos', :action => 'add_comment'
  map.photo_manage_comment '/photo_comment/:id/:change_to/:comment_id', :controller => 'photos', :action => 'manage_comment'
  map.photo_vote '/photo/vote_list/:id', :controller => 'photos', :action => 'photo_vote_list'
  
  
  map.sitemap '/sitemap.xml', :controller => 'sitemap', :action => 'xml'
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  # map.connect ':controller/:action/:id.:format', :format => 'html'
  map.connect ':controller/:action/:id'#
    
  map.connect '*path', :controller => 'error' #page not found
end
