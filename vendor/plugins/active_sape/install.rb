require "fileutils"

plugin_root = File.join(Rails.root, "vendor", "plugins", "active_sape")
FileUtils.cp(File.join(plugin_root, "sape.yml"), File.join(Rails.root, "config"))
