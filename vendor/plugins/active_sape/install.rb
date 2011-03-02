require "fileutils"

plugin_root = File.join(RAILS_ROOT, "vendor", "plugins", "active_sape")
FileUtils.cp(File.join(plugin_root, "sape.yml"), File.join(RAILS_ROOT, "config"))
