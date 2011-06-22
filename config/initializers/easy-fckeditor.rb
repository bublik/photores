# make plugin controller available to app
Photores::Application.config.load_paths += %W(#{Fckeditor::PLUGIN_CONTROLLER_PATH} #{Fckeditor::PLUGIN_HELPER_PATH})

ActionController::Base.helper(Fckeditor::Helper)

# add a route for spellcheck
Photores::Application.routes.draw do
  match 'fckeditor/check_spelling' => 'fckeditor#check_spelling'
  match 'fckeditor/command' => 'fckeditor#command'
  match 'fckeditor/upload' => 'fckeditor#upload'
end