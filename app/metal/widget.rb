require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'iconv'

class Widget
  def self.call(env)
    signon_app = PhotoWidget.new
    signon_app.call(env)
  end
end


class PhotoWidget
  attr_reader :request, :session, :params
  include ActionView::Helpers

  def call(env)
    @request = Rack::Request.new(env)
    @params = @request.params
    case env["PATH_INFO"] 
    when /^\/widget_last_photos/ then
      last_photos     
    when /^\/widget_user_photos/ then
      user_photos
    when /^\/widget_random_photos/ then
      random_photos
    else
      [404, {"Content-Type" => "text/plain"}, ["Not Found!"]]
    end
  end
  
=begin
Последние фотографии
<script language="Javascript" type="text/javascript" src="http://<%= APP_CONFIG['domain'] %>/widget_last_photos.js"></script>
<script language="Javascript" type="text/javascript" src="http://<%= APP_CONFIG['domain'] %>/widget_last_photos.js?limit=9&width=300&height=300&charset=cp-1251"></script>
=end
  def last_photos
    content = imageslist(Photo.parents.limit(params['limit'] || 6))
    css = css_header(params['width'], params['height'])
    resp = encode("document.write('#{content}');\n"+ css, params['charset'])
    [200, {"Content-Type" => "text/javascript"}, [resp]]
  end

=begin
Случайные фоторафии пользователя
<script language="Javascript" type="text/javascript" src="http://<%= APP_CONFIG['domain'] %>/widget_user_photos.js?login=admin&charset=cp-1251"></script>
=end
  def user_photos
    if user = User.find_by_login(params['login']) #|| User.random.first
      content = imageslist(user.random_photos(params['limit'] || 6))
      css = css_header(params['width'], params['height'])
      resp = encode("document.write('#{content}');\n"+ css, params['charset'])
      [200, {"Content-Type" => "text/javascript"}, [resp]]
    else
      [404, {'Content-Type' => 'text/html'}, ['User Not Found']]
    end
  end

=begin
Случайные фотографии
<script language="Javascript" type="text/javascript" src="http://<%= APP_CONFIG['domain'] %>/widget_random_photos.js"></script>
<script language="Javascript" type="text/javascript" src="http://<%= APP_CONFIG['domain'] %>/widget_random_photos.js?limit=9&width=300&height=300&charset=cp-1251"></script>
=end
  def random_photos
    content = imageslist(Photo.random.parents.limit(params['limit'] || 6))
    css = css_header(params['width'], params['height'])
    resp = encode("document.write('#{content}');\n"+ css, params['charset'])
    [200, {"Content-Type" => "text/javascript"}, [resp]]
  end

  private
  def css_header(width, height)
    #2 горизонтально 3 вертикально
    width ||= '148'
    height ||='245'
    "document.write('<style>.ph_widget_box{clear:both; width: #{width}px; min-height:#{height}px; font-size:8px;}</style>');\n"+
      "document.write('<style>.ph_widget_box a{width:62px; height:75px; display:inline-block; float:left; text-align: center; padding: 5px 5px 0 5px; text-decoration:none; border:1px solid #CCCCCC;}</style>');\n" +
      "document.write('<style>.ph_widget_box a div img{width:52px; height:52px; display:inline-block;}</style>');\n" +
      "document.write('<style>.ph_widget_box a div{text-align:center; overflov:hidden;line-height:10px;}</style>');\n" +
      "document.write('<div style=\"clear:both;\"></div>');"
  end
  
  def imageslist(images)
    cont = images.collect{|ph|
      link_to(content_tag(:div, crop_image(ph)) +
          content_tag(:div, truncate(h(ph.title), :length => 15, :omission => '')), "http://#{APP_CONFIG['domain']}/photos/#{ph.to_param}.html")
    }
    content_tag(:div, cont, :class => 'ph_widget_box')
  end
  
  def crop_image(photo)
    image_tag(photo.public_filename(:crop), :alt => '')
  end

  def encode(str, charset = nil)
    return str if charset.nil?
    Iconv.iconv(charset, 'UTF-8', str).join
  end
end
