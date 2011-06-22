directory = File.join(Rails.root, '/vendor/plugins/easy-fckeditor/')
require "#{directory}lib/fckeditor_file_utils"
require "#{directory}lib/fckeditor_version"
require "#{directory}lib/fckeditor"

puts "** Uninstalling Easy FCKEditor Plugin version #{FckeditorVersion.current}...."

FckeditorFileUtils.destroy
