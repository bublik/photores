atom_feed do |feed|
  feed.title "Фотографии на #{APP_CONFIG['site_name']}"
  feed.updated((@photos.first ? @photos.first.created_at : Time.now))
  
  for photo in @photos
    tags = '<br/>'+photo.tags.collect{|t|  
                link_to(t.name, photo_tag_path(t.name),
                  :title=>t.name, :rel=>'tag friend colleague')
              }.join(', ')
    feed.entry(photo, {:url => photo_url(photo, :html)}) do |entry|
      entry.title(photo.title)
      entry.content(small_image(photo) + tags , :type => 'html')
      entry.author do |author|
        author.name(photo.user.full_name)
      end
      
    end
  end
end