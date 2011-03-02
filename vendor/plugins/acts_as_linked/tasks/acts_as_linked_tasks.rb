require 'fileutils'

require File.join(File.dirname(__FILE__), '../lib/migrate/create_sites_categories')
require File.join(File.dirname(__FILE__), '../lib/migrate/create_friend_sites')

namespace :linked do
  Rake::Task[:environment].invoke if defined?(RAILS_ROOT)

  desc "Add tables [Sites, FriendSites]"
  task :migrate_up do
    CreateSitesCategories.up
    CreateFriendSites.up
  end
  
  desc "Remove tables [Sites, FriendSites]"
  task :migrate_down do
    CreateFriendSites.down
    CreateSitesCategories.down
  end
end


