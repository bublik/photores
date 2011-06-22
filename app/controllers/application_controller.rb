class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable
  include SimpleCaptcha::ControllerHelpers
  include Geokit

  helper :all
  protect_from_forgery :only => [:edit, :update, :delete]

  before_filter :check_domain
  before_filter :ckeck_black_list
  after_filter :clear_flash
  layout :set_layout

  def check_domain
    request.domain(2)
    logger.debug("APP_CONFIG: "+APP_CONFIG['site_name'].inspect)
    if current_subdomain && (@subdomain_owner = User.first(:conditions => ['lower(subdomain) = lower(?)', current_subdomain])).nil?
      flash[:flash] = "Blog invalid"
      redirect_to(root_url(:subdomain => false), :status => 301)
      return
    else
      if request.host.match("www.#{APP_CONFIG['domain']}") || (current_subdomain && request.fullpath.match('/messages'))
        redirect_to("http://#{APP_CONFIG['domain']}#{request.fullpath}", :status => 301)
        return
      end
    end
  end

  def current_subdomain
    @subdomain ||= request.subdomain(2)
    @subdomain = nil if @subdomain.blank?
  end
  helper_method :current_subdomain

  def set_layout
    current_subdomain ? 'blog' : 'index'
  end

  def search_bots
    robots = ['Spider', 'Meta', 'Google', 'Stack', 'Rambler', 'StackRambler','Aport', 'Yahoo', 'MSN', 'Yandex', 'bot', 'MSIE incompatible']
    user_agent = request.env['HTTP_USER_AGENT'].to_s
    robots.detect{ |bot| bot if user_agent.match(bot)}
  end

  def ckeck_black_list
    #62.149.4.46  METASpider
    if request.env["HTTP_USER_AGENT"] =~ /WebCopier|Curl|Wget/
      render_404
      return
    end
  end

  def clear_flash
    if Rails.env.eql?('development')
      logger.debug("SUBDOMAIN: #{current_subdomain}")
      logger.debug("FLASH: #{flash.inspect}")
    end
    flash.discard if request.xhr?
  end
end
