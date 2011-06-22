require 'subdomain'

Photores::Application.routes.draw do
  resources :wikis

  resources :priv_messages
  resources :contests
  resources :photo_profiles
  resources :camera_brands
  resources :attachments
  resources :users
  resources :bcomments

  match '/forums/list' => 'forums#list', :as => :forum_list

  match '/messages/rss' => 'messages#rss', :as => :messages_rss
  resources :messages,
            :member => {:replay => :any },
            :collection => {:list => :get, :last_posts => :get}
  match '/messages/:id/rate/:rate' => 'messages#rate', :as => :rate_message
  match '/messages/tag/*tag_name' => 'messages#tag', :as => :tagging
  match '/wiki/tag/*tag_name' => 'wikis#tag', :as => :wiki_tag
  match '/user/:id/messages' => 'messages#user_msg_list', :as => :user_messages
  match '/user/:id/votes' => 'messages#user_vote_list', :as => :user_votes
  match '/user/:id/widget' => 'users#widget', :as => :user_widget
    
  resources :photos do
    member do
      get 'download'
      get 'complaint'
    end
    collection do
      get 'colors'
    end
  end

  resources :photo_albums
  resources :photo_categories
  resources :blogs
  resources :fgroups
  match '/login' => 'login#login', :as => :login
  match '/logout' => 'login#logout', :as => :logout
  match '/mobile_payment' => 'progect#mobile', :as => :mobile

  resources :users do
    resources :blogs
    resources :photo_albums
    resources :friends
  end
  resources :blogs, :has_many => :bcomments

  match '/search/*word' => 'finder#find', :as => :search

  match '/blogs/tag/*id' => 'blogs#tag', :as => :blogtag
  match '/blogs/:id/rate/:rate' => 'blogs#rate', :as => :rate_blog

  root :to => 'photos#index'
  constraints(Subdomain) do
	match '/' => 'users#show', :as => :user_root
  end

  #user_root '', :controller => 'users', :action => 'show', :conditions => { :subdomain => /.+/ }


  resources :sites_categories, :has_many => :friend_sites
  match '/friend_sites_activation/:id/:state' => 'friend_sites#activation', :as => :friend_site_activate
  match '/friend_sites_validation/:id' => 'friend_sites#remote_validation', :as => :friend_site_remote_validation
  
  match '/project/:action' => 'progect', :as => :progect
  match '/photos/:id/rate/:rate' => 'photos#rate', :as => :rate_photo
  match '/photo_row/:id' => 'photos#photo_row', :as => :photo_row
  match '/photo_notes/:id.:format' => 'photos#show_notes', :as => :show_notes
  match '/photo_notes/add/:id' => 'photos#add_note', :as => :add_note
  match '/photo_rotate/:id/:to/*page' => 'photos#rotate', :as => :photo_rotate
  match '/photos/tag/*tag_name' => 'photos#tag', :as => :photo_tag
  match '/photos/add_comment/:id' => 'photos#add_comment', :as => :photo_comment
  match '/photo_comment/:id/:change_to/:comment_id' => 'photos#manage_comment', :as => :photo_manage_comment
  match '/photo/vote_list/:id' => 'photos#photo_vote_list', :as => :photo_vote
  
  
  match '/sitexml' => 'sitemap#xml', :as => :sitemap
  match '/simple_captcha/:action' => 'simple_captcha', :as => :simple_captcha

  match "/:controller(/:action(/:id))(.:format)"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

end
