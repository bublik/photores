xml.instruct! :xml, :version=>"1.0" 
    xml.rss(:version => "2.0" ,
	    "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
	    "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/",
	    "xmlns:dc" => "http://purl.org/dc/elements/1.1/"){
       xml.channel{
       xml.title(APP_CONFIG['site_name'])
       xml.link('http://' + request.host)
       xml.description(APP_CONFIG['description'])

       xml.language('ru-ru')
       for post in @blogs
         tags = '<br/>'+post.tags.collect{|t|  
                link_to(t.name, {:controller => 'blogs', :action => 'tag', :id => t.name}, :title => t.name, :rel => 'tag friend colleague')
              }.join(', ')
        xml.item do
          xml.title(post.title)
          xml.author(post.user.full_name)
          xml.pubDate(post.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          xml.description(simple_format(post.body) + '<br/>' + tags)
          xml.guid(url_for(:only_path => false, :controller => 'blogs', :action => 'show', :id => post))
          xml.link(url_for(:only_path => false, :controller => 'blogs', :action => 'show', :id => post))
         # xml.guid
        end
       end
       }
    }
