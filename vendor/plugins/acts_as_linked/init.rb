require 'hpricot'
require 'net/http'
require 'uri'

#ActionController::Base.send(:include, FriendSitesController)
#ActionController::Base.send(:include, SitesCategoriesController)

models_path = File.join(directory, 'app', 'models')
$LOAD_PATH << models_path
ActiveSupport::Dependencies.load_paths << models_path


controller_path = File.join(directory, 'app', 'controllers')
$LOAD_PATH << controller_path
ActiveSupport::Dependencies.load_paths << controller_path
config.controller_paths << controller_path


ActionController::Base.append_view_path File.join(directory, 'views')

# Include this module into views, too.
ActionController::Base.helper(FriendSitesHelper)
ActionController::Base.helper(SitesCategoriesHelper)

