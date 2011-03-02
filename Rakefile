require(File.join(File.dirname(__FILE__), 'config', 'boot'))
require 'rubygems'
require 'activerecord'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
$KCODE = "utf8"
require 'thinking_sphinx/tasks'

namespace :photo do
  desc 'Download new photos: rake photo:download RAILS_ENV=production USER_LOGIN=admin [PAGES=number_google_pages SEARCH_WORD=цветы]'
  task :download do
    require 'cgi'
    require 'mechanize'
    require 'img_harvester'
    if ENV['USER_LOGIN'].blank?
      puts 'USE $rake photo:download RAILS_ENV=production USER_LOGIN=admin PAGES=2  SEARCH_WORD=строительство'
      return
    end
    
    search_keyword = ENV['SEARCH_WORD'] || Tag.find(:first, :conditions => ["is_uploadet = ?", false]).name
    return if search_keyword.nil?

    harv = ImgHarvester.new(search_keyword, ENV['PAGES'] || 2, ENV['USER_LOGIN'])
    #
    harv.storage_dir = "#{RAILS_ROOT}/tmp"
    harv.logger = Logger.new("#{RAILS_ROOT}/log/image-parser.log")
    #Mark tag as uploadet
    Tag.find_by_name(search_keyword).update_attribute('is_uploadet', true) if ENV['SEARCH_WORD'].nil?
    begin
      harv.parse!(ENV['PAGES'] || 2)
    rescue
    end
    #Mailer.deliver_system_msg(harv.user, 'NEW photos added!')
    Rake::Task["ts:index"].invoke
  end

  desc "Photo import from PDIR=/tmp/imahes_dir/ PUSER=site_login "
  task :import do
    require 'img_harvester'
    #  files = `find . -name '*.jpg'`
    require 'find'

    harv = ImgHarvester.new
    harv.user = User.find_by_login(ENV['PUSER'])
    harv.logger = Logger.new("#{RAILS_ROOT}/log/image-comiter.log")

    Find.find(ENV['PDIR']) do |file_path|
      if FileTest.directory?(file_path)
        if File.basename(file_path)[0] == ?.
          Find.prune       # Don't look any further into this directory.
        else
          next
        end
      else
        next unless file_path.match(/(.jpg|.jpeg)$/)
        puts file_path
        file_name = File.basename(file_path)
        harv.save_local_image(file_path)
        #Remove used image
        File.delete(file_path)
        sleep(3)
      end
    end
     Rake::Task["ts:index"].invoke
  end

end

desc "Create histograms for Photos"
task :create_hists do
  require 'config/environment'
  require 'RMagick'
  NUM_COLORS = 10

  Photo.thumbnails('thumb').each do |record|
    img = Magick::Image.read(record.full_filename).first
    img = img.quantize(NUM_COLORS)
    hist = img.color_histogram
    pixels = hist.keys.sort_by {|pixel| hist[pixel] }
    pixels.each do |pixel|
      h = Histogram.create!(
        :photo_id => record.parent_id,
        :r => pixel.red, :g => pixel.green, :b => pixel.blue,
        :y => 66*pixel.red + 129*pixel.green + 25*pixel.blue,
        :u => -38*pixel.red - 74*pixel.green + 112*pixel.blue,
        :v => 112*pixel.red - 94*pixel.green - 18*pixel.blue,
        :count => hist[pixel])
    end
    record.save
  end
end

desc "Update gems (update URL http://gems.rubyforge.org/yaml) from file /config/gem_list.yml"
task :update_gems do
  require 'config/environment'
  #Geml.destroy_all
  
  YAML.load_file("#{RAILS_ROOT}/config/gem_list.yml").collect do |k|
    @gems = Geml.find(:first, :conditions => ['gemname = ?', k[0]])
    if @gems.nil?
      @gems = Geml.new
    end
    @gems.gemname=k[0]
    p   k[1].name
    @gems.name=k[1].name
    @gems.authors=k[1].authors.collect{|a|  a.nil? ? '' : a }
    @gems.extra_rdoc_files=k[1].extra_rdoc_files.collect{|extra|  "#{extra.inspect}\n"} unless k[1].extra_rdoc_files.nil?
    @gems.platform=k[1].platform
    @gems.has_rdoc=k[1].has_rdoc
    @gems.email=k[1].email
    @gems.summary=k[1].summary
    @gems.post_install_message=k[1].post_install_message
    @gems.specification_version=k[1].specification_version
    @gems.version=k[1].version
    @gems.extensions=k[1].extensions
    @gems.files=k[1].files.collect{|f| "#{f} \n"} unless k[1].files.nil?
    @gems.autorequire=k[1].autorequire
    @gems.executables=k[1].executables.collect{|ex|  "#{ex} \n"} unless k[1].executables.nil?
    @gems.require_paths=k[1].require_paths
    @gems.dependencies=k[1].dependencies.collect{|dep| "#{dep} \n"} unless k[1].dependencies.nil?
    @gems.rubygems_version=k[1].rubygems_version
    @gems.date=k[1].date
    @gems.cert_chain=k[1].cert_chain.collect{|ch| "#{ch} \n"} unless k[1].cert_chain.nil?
    @gems.test_files=k[1].test_files
    @gems.default_executable=k[1].default_executable
    @gems.rubyforge_project=k[1].rubyforge_project
    @gems.rdoc_options=k[1].rdoc_options.collect{|rd|  "#{rd} \n"} unless k[1].rdoc_options.nil?
    @gems.required_ruby_version=k[1].required_ruby_version.inspect
    @gems.bindir=k[1].bindir
    @gems.signing_key=k[1].signing_key
    @gems.requirements=k[1].requirements.collect{|req|  "#{req} \n"} unless k[1].requirements.nil?
    @gems.homepage=k[1].homepage
    @gems.description=k[1].description

    if @gems.save
      p @gems.authors
    else
      p "error\n"
    end
  end

end
 
task "utf8doc" do
  require 'rdoc/rdoc'
  rdoc = RDoc::RDoc.new
  options = Array.new
  #options << '-a'   # parses all methods (include protected, private)
  options << '-cUTF-8' # you may want to set the charset
  options << '-odoc/apputf8'
  options << '--line-numbers'
  options << '--inline-source'
  options << '-Thtml'
  options << 'doc/README_FOR_APP'
  Dir.glob('app/**/*.rb').each do |file|
    options << file
  end
  rdoc.document(options)
end

desc "Configure Subversion for Rails"
task :configure_for_svn do
  system "svn remove log/*"
  system "svn commit -m 'removing all log files from subversion'"
  system 'svn propset svn:ignore "*.log" log/'
  system "svn update log/"
  system "svn commit -m 'Ignoring all files in /log/ ending in .log'"
  system 'svn propset svn:ignore "*.db" db/'
  system "svn update db/"
  system "svn commit -m 'Ignoring all files in /db/ ending in .db'"
  system "svn move config/database.yml config/database.example"
  system "svn commit -m 'Moving database.yml to database.example to provide a template for anyone who checks out the code'"
  system 'svn propset svn:ignore "database.yml" config/'
  system "svn update config/"
  system "svn commit -m 'Ignoring database.yml'"
  system "svn remove tmp/*"
  system "svn commit -m 'Removing /tmp/ folder'"
  system 'svn propset svn:ignore "*" tmp/'
end
   
desc "Add new files to subversion"
task :add_new_files do
  system "svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add"
end

desc "shortcut for adding new files"
task :add => [ :add_new_files ]

namespace :db do
  namespace :fixtures do

    desc 'Create YAML test fixtures from data in an existing database.
Defaults to development database. Set RAILS_ENV to override.'
    task :dump_all => :environment do
      sql = "SELECT * FROM %s"
      skip_tables = ["schema_info"]
      ActiveRecord::Base.establish_connection(:development)
      (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
        i = "000"
        File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end
  end
  
  namespace :fixtures do
    desc 'Create YAML test fixtures for references. Defaults to development database.
    Set RAILS_ENV to override.'
    task :dump_references => :environment do
      sql = "SELECT * FROM %s"
      dump_tables = ["areas","countries"]
      ActiveRecord::Base.establish_connection(:development)
      dump_tables.each do |table_name|
        i = "000"
        file_name = "#{RAILS_ROOT}/test/fixtures/#{table_name}.yml"
        p "Fixture save for table #{table_name} to #{file_name}"
        File.open(file_name, 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end
  end
end 

