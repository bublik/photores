xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0" , 
  "xmlns:content"=>"http://purl.org/rss/1.0/modules/content/",
  "xmlns:media"=>"http://search.yahoo.com/mrss/",
  "xmlns:wfw"=>"http://wellformedweb.org/CommentAPI/",
  "xmlns:dc"=>"http://purl.org/dc/elements/1.1/"){
  xml.channel{
    xml.title(APP_CONFIG['site_name'])
    xml.link('http://'+APP_CONFIG['domain'])
    xml.description(APP_CONFIG['description'])

    xml.language('ru-ru')
    for photo in @photos
      tags = '<br/>' +
        photo.tags.collect{|t| link_to(t.name, photo_tag_path(t.name), :title => t.name, :rel=>'tag friend colleague')}.join(', ')
      xml.item do
        xml.title(photo.title)
        xml.author(photo.user.full_name)
        xml.pubDate(photo.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.description(small_image(photo) + tags)
        xml.guid(url_for(:only_path => false, :controller => 'photos', :action => 'show', :id => photo, :format => 'html'))
        xml.link(url_for(:only_path => false, :controller => 'photos', :action => 'show', :id => photo, :format => 'html'))
        xml.media(:content, photo.public_filename(:medium))
        xml.media(:thumbnail, photo.public_filename(:crop))
      end
    end
  }
}
