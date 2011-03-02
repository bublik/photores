# == Columns ==
#t.references :sites_category
#t.string :url, :null => false
#t.string :button_url, :null => true
#t.string :description, :default => nil
#t.string :admin_email, :null => false
#t.string :refered_page, :default => nil
#t.boolean :is_active, :default => false

#require 'hpricot'
#require 'net/http'
#require 'uri'
class FriendSite < ActiveRecord::Base
  belongs_to :sites_category
 
  attr_protected :is_active
  attr_accessor :remote_check
  
  validates_associated :sites_category
  validates_uniqueness_of :url, :refered_page, :allow_nil => false
  validates_length_of :description, :in => 7..255, :allow_blank => false
  validates_format_of :admin_email, :with => /^(.+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'имеет не верный формат'
  validates_format_of :url, :with => /^http:\/\/((?:[-a-z0-9]+\.)+[a-z]{2,})/i, :message => 'имеет не верный формат'
  validates_format_of :button_url, :with => /^http:\/\/((?:[-a-z0-9]+\.)+[a-z]{2,}).*/i, :allow_blank => true, :message => 'имеет не верный формат'
  validates_format_of :refered_page, :with => /^http:\/\/((?:[-a-z0-9]+\.)+[a-z]{2,}).*/i, :message => 'имеет не верный формат'
  named_scope :active, :conditions => ['is_active = ?', true]
  named_scope :not_active, :conditions => ['is_active = ?', false]
  

  HUMANIZED_ATTRIBUTES = {
    :admin_email => 'E-mail администратора сайта ',
    :url => 'Урл вашего сайта ',
    :button_url => 'Ссылка на кнопку ',
    :captcha => 'Защитный код ',
    :refered_page => 'Страница с обратной ссылкой '
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
 
  def validate_on_create
    if self.errors.empty?
      #skip remote validation if set this flag
      return true unless remote_check 
      remote_validation
    end
  end
  
  def remote_validation
    if self.refered_page.scan(self.url)
      links = Link.new
      links.set_page(self.refered_page)
      links.link_initialize
      logger.debug(links.ext_links.inspect)
      links.ext_links.each do |url|
        return self.is_active = true if url.scan(APP_CONFIG['domain'])
      end
      self.errors.add_to_base('На указанной Вами странице обратной ссылки не найдено.')
    else
      self.errors.add_to_base('Ссылка нанаш русурс размещена на чужом сайте.')
    end
    self.is_active = false
  end

  class Link
    attr_accessor :site, :indexed_links, :int_links, :ext_links

    def initialize(site = nil)
      parse_site_name(site)
    end
  
    def set_page(site)
      @site = site
      @ext_links = []
      @int_links = []
      parse_site_name(site)
    end
  
    def parse_site_name(site)
      return if site.nil?
      uri = URI.parse(site) #'http://www.example.com/index.html'
      @host = uri.host
      @host = site if @host.nil? && !site.nil?
      @port = '80' if @port.nil?
      @path = uri.path
    end
  
    def host
      @host
    end
  
    def link_initialize
      page = get_page
      return if page.nil?
      doc = Hpricot.parse(page.body)

      #doc = Hpricot.parse(@@demo)
      @no_index = doc.search('noindex').search("a")
      @no_follov = doc.search("//a[@rel='nofollov']")
      @all_links = doc.search("a")
      @indexed_links = @all_links - @no_follov - @no_index
    
      @relativ_links = @indexed_links.collect{|link| link if link.attributes['href'] && link.attributes['href'].scan(/http:\/\//).empty?}

      @relativ_links.each do |hr|
        next unless hr
        href = hr.attributes['href']
        next if !href.scan(/^#.*/).empty?
        next if !href.scan(/^javascript:/).empty?
        next if !href.scan(/^mailto:/).empty?
        @int_links << href
      end
    
      @uri_links = @indexed_links - @relativ_links
      @uri_links.each do |link|
        next unless href = link.attributes['href']
        if URI.parse(href).host.eql?(@host)
          # 0        1     2                3     4   5           6     7
          #["http", nil, "fotolife.com.ua", nil, nil, "",         nil, "page=soft&blok=all", nil]
          #[nil,    nil,  nil,              nil, nil, "",         nil, "page=viev_album&image_id=5796", nil]
          #[nil,    nil,  nil,              nil, nil, "/",        nil, "page=viev_album&image_id=2700", nil]
          #["http", nil, "fotolife.com.ua", nil, nil, "/lesonph/", nil, nil, nil]
          #href = intel[5].to_s+(intel[7].nil? ? '' : "?#{intel[7]}")
        
          @int_links << href
        else
          @ext_links << href
        end
   
      end
    end
  
    def get_page(host = @host, path = @path, port = @port)
      port ||= 80
      begin
        req = Net::HTTP::Get.new(path)
        puts "Request HOST #{host}"
        puts "Request Path #{path}"
        res = Net::HTTP.start(host, port) {|http|
          http.request(req)
        }
        logger.debug(res.inspect)
      rescue Exception => e

      ensure
        return res
      end
    end
  
    def ya_tic
      #http://bar-navig.yandex.ru/u?ver=2&show=32&url=http://$url xml ответ по рейтингу (не постоянно отчечает)
      #http://www.yandex.ru/cycounter?ukrainaonline.net картинка
      #http://search.yaca.yandex.ru/yca/cy/ch/fotolife.com.ua
      #http://www.yandex.ru/yandsearch?serverurl=http://fotolife.com.ua&lr=187 количество страниц
      #http://search.yaca.yandex.ru/yandsearch?text=cocos.com.ua&rpt=rs2&doSearch=%CD%E0%E9%F2%E8 поиск сайта покаталогу
      page = get_page('search.yaca.yandex.ru', "/yandsearch?text=#{@host}&rpt=rs2&doSearch=%CD%E0%E9%F2%E8")
      doc = Hpricot.parse(page.body)
      if !doc.search("ol[@class='results']").empty?
        rubrika = doc.search('/html/body/table[2]/tbody/tr/td/ol/li/div[2]')
        tic_region = doc.search('/html/body/table[2]/tbody/tr/td/ol/li/div/span[2]')
        { :html_rubrika => rubrika.html,
          :text_rubrika => rubrika.inner_text,
          :html_tic => tic_region.html,
          :text_tic => tic_region.inner_text,
          :counter => tic_region.inner_text.scan(/\d+/).last
        }
      else
        page = get_page('search.yaca.yandex.ru', "/yca/cy/ch/#{@host}")
        doc = Hpricot.parse(page.body)
        tic = doc.search("p[@class='errmsg']")
        {:counter => tic.inner_text.scan(/\d+/).last }
      end
    end

  end
end
################################################################################
