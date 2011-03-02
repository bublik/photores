require "php_serialize"
require "net/http"
require "uri"

class ActiveSape

  def initialize(options = {})
    @page_keys = []
    @options = options
    @adv_system_vars = {}
    @pages = {}
    @cache_lifetime = options[:cache_lifetime] || 3600
    @read_timeout_sec = 2
    @open_timeout_sec = 2
    @sleep_time = 20 * 60 # 20 minut 
    @last_update = Time.now - @cache_lifetime
    @force_show_code = options['force_show_code'] || false
    @advert_host = options['advert_host']
    @user = options['user'] || '97ab6f9a4c02f65e84e3255d304b51b6'
    @sape_dom = options['sape_dom'] || '188.72.80.12' #'dispenser-01.sape.ru'
    @charset = options['charset'] || 'UTF-8'
    
  end
  
  def show_links(request, limit = 100, offset = 0)
    get_links_db
    return '<!-- no sp data-->' unless @adv_system_vars['__sape_ips__']
    #  Rails.logger.debug(get_links_db.inspect)
    if @force_show_code || @adv_system_vars['__sape_ips__'].include?(request.remote_ip)
      resp = @force_show_code ? ' <!--check code--> ' : ''
     # Rails.logger.info("Sape Boot:  #{@adv_system_vars['__sape_new_url__']}")
      "#{resp} #{@adv_system_vars["__sape_new_url__"]}".strip
    else
      #recogn_path = ActionController::Routing::Routes.recognize_path(request.path).to_s
      md5_path = Digest::MD5.hexdigest(request.env['REQUEST_URI'].gsub(/\/$/,''))
      #      Rails.logger.debug("!! request.path #{request.path}
      #  request.env['REQUEST_URI'] #{request.env['REQUEST_URI']}
      #  request.env['QUERY_STRING']  #{request.env['QUERY_STRING']} ")
      
      if @pages.key?(md5_path)
        links_str = ""
        links = @pages[md5_path][offset, limit]
        unless links.nil? || links.blank?
          links.each{|link| links_str << "#{link} #{@adv_system_vars['__sape_delimiter__']}"}
        end
        links_str
      end
    end
  end
  
  def get_links_db(server  = @sape_dom, port = 80)
    return 'Disabled get links or Update time not now' if !@options['get_links'] || (Time.now < @last_update + @cache_lifetime)# && !@@adv_system_vars.empty?)
    @last_update = Time.now
    
    path = "/code.php?user=#{@user}&host=#{@advert_host}&charset=#{@charset}"
    Rails.logger.info("#{path}\n NOW: "+Time.now.to_s + " last update #{@last_update}")
    begin
      req = Net::HTTP.new(server, port)
      req.open_timeout = @open_timeout_sec
      req.read_timeout = @read_timeout_sec
      
      req.start do |http|
        links_hash = {}
        http.request_get(path) { |res|
          unless res.nil?
            links_hash = PHP.unserialize(res.body)
          else
            @last_update += @sleep_time
          end
        }

        #Очищаем старые переменные и страницы
        unless links_hash.empty?

          @adv_system_vars = @pages = {}
          #Разбиваем на две части хеш на хеш рекламной системы и на рекламные страницы
          links_hash.each do |key, val|
            key = CGI.unescape(key)
            @page_keys << key.gsub(/\/$/, '')
            key.match(/^__(.*)__$/) ? 
              (@adv_system_vars[key] = val) :
              (@pages[Digest::MD5.hexdigest(key.gsub(/\/$/, ''))] = val)
          end
        end
      end
    rescue Exception => err
      err
    end
  end

  def pages_hash
    @pages
  end
end
