require 'hpricot'
require 'net/http'
require 'uri'
require 'authenticated_system'
#ActionController::Base.send(:include, FriendSitesController)
#ActionController::Base.send(:include, SitesCategoriesController)

# Include this module into views, too.
ActionController::Base.helper(FriendSitesHelper)
ActionController::Base.helper(SitesCategoriesHelper)

