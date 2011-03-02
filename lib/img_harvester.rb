require 'cgi'
require 'rubygems'
require 'mechanize'
require 'logger'
$KCODE = "utf8"

class ImgHarvester
=begin
Загрузка фотографий в большом размере примерно 1024Х800 по ключевым словам

  harv = ImgHarvester.new("чернобелые фото", pages = 10)
   Загрузка всех фотографий с 10 страниц - 200 фото
  harv.parse_all_pages
   Загрузка фотографий с 10 страницы - 20 фото
  harv.parse_and_download(10)
=end
  attr_accessor :logger
  attr_accessor :storage_dir
  attr_accessor :user
  
  #TODO add to initialize save images path
  def initialize(search_text = 'photo', pages = 10, user_login = nil)
    @agent = WWW::Mechanize.new
    @user = User.find_by_login(user_login)
    @search_text = search_text
    #Large photo
    @current_page = 'http://images.google.com.ua/images?imgsz=xxlarge&imgtype=photo&as_st=y&gbv=2&ndsp=21&hl=ru&q='+CGI.escape(search_text)+'&sa=N&start='
    @limit_pages = pages.to_i
  end

  def parse!(limit = 9) #limit pages
    Array.new.fill(1, 0..limit.to_i).fill{|i| i*21}.each do|page_number| # [0, 21, 42, 63, 84, 105, 126, 147, 168, 189]
      parse_and_download(page_number)
    end
  end

  def parse_and_download(page_number)
    images_links = []
    logger.info("Start get page: #{@current_page}#{page_number}")
    resp = @agent.get("#{@current_page}#{page_number}")
    resp.body.scan(/imgurl=(http:\/\/\S+)&img/).each do |l|
      logger.debug("LINK #{l.to_s}")
      images_links << l.to_s
    end

    logger.info("All links: #{images_links.size}")
    logger.debug(images_links.inspect)
    save_images(images_links, page_number)
  end

  def save_images(images_links = [], page = 0)
    FileUtils.mkdir_p "#{@storage_dir}/images_#{page}"

    images_links.each_with_index do |file,index|
      logger.debug("Get image #{file}")
      file_name = File.basename(file)
      save_tmp_path = "#{@storage_dir}/images_#{page}/#{index}_#{file_name}"

      begin
        #Download and save image
        @agent.get(file).save_as(save_tmp_path)
        img_saved = true
      rescue
        logger.warn("Failed get and save image #{file}")
      end

      if img_saved
        p = Photo.new
        #p.user = User.find(:first, :order => "RANDOM()")
        p.user = @user
        p.filename = file_name
        p.temp_path = File.open(save_tmp_path)
        p.content_type = mime_type_for_file(save_tmp_path)
        p.title = 'NEW '+@search_text
        p.is_moderated = false
        if p.valid? && p.save
          logger.info("Image uploadet: #{file_name}")
        else
          logger.debug(p.errors.full_messages)
        end
        #Remove uploadet image
        File.delete(save_tmp_path) if File.exist?(save_tmp_path)
      end
      sleep(3)
    end
  end

=begin
Сохрание фотографий на сайте из директории на сервере
=end
  def save_local_image(img_path = nil)
    return unless img_path
    
    p = Photo.new
    file_name = File.basename(img_path)
    p.user = @user
    p.filename = file_name
    p.temp_path = File.open(img_path)
    p.content_type = mime_type_for_file(img_path)
    p.title = "NEW #{file_name}"
    p.is_moderated = false
    if p.valid? && p.save
      logger.info("Image saved to site: #{file_name}")
    else
      logger.debug(p.errors.full_messages)
    end
  end

  def mime_type_for_file(file_path)
    type = `file -i #{file_path}`
    type.split(' ')[1]
  end

  def logger=(obj)
    @logger = obj
  end

end

#harv = ImgHarvester.new("чернобелые фото")
##harv.parse_and_download(page_number)
#harv.parse_all_pages