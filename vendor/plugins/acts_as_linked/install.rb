 File.open(File.join(Rails.root, '/vendor/plugins/acts_as_linked/', 'README')).each do |f|
   print f.gets 
 end
 
`rake linked:migrate_up`
