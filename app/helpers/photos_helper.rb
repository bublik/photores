module PhotosHelper
  include AuthenticatedSystem

  def map_block(map = nil, size = [500, 290], form = nil)
    return '<!--map position not defined-->' if map.nil?
    resp = GMap.header(:hl => 'ru', :host => APP_CONFIG['domain']) +
      content_tag(:div, map.to_html + map.div(:width => size[0], :height => size[1]), :class => 'pad5')
    if form
      resp << form.hidden_field(:lat)
      resp << form.hidden_field(:lng)
    end
    resp
  end

  def color_line
    content_tag(:ul, (Array.new(9){|i| i+1 }+[1]).collect{|style| content_tag(:li, '&nbsp;', :class => "bg#{style}",
                :onmouseover => "$('.main_image').css('backgroundColor', $('.bg#{style}').css('backgroundColor'));",
               :onmouseout => "$('.main_image').css('backgroundColor','#fff')")}, :class => 'background')
  end

  def thumb_image(photo)
    content_tag(:div, link_to(image_tag(photo.public_filename(:thumb), :alt => photo.alt), 
        photo_path(photo, :html), :title => photo.alt))
  end
  
  def random_user_photos(user = nil) 
    return '' unless user
    content_tag(:ul,
      user.random_photos(5).collect{|ph|
        content_tag(:li,
          content_tag(:div, crop_image(ph) +
              content_tag(:small, ph.created_at.to_s(:db)) +
              content_tag(:h2, link_to(truncate(h(ph.title), :length => 20, :omission => ''), photo_url(ph, {:format => :html, :subdomain => false}))
            ), :class => 'block center')
        )}
    )
  end


  def photo_tags_links(photo)
    return '&nbsp;' if photo.tags.empty?
    photo.tags.collect{ |t| link_to(h(t.name), photo_tag_path(CGI.escape(t.name)), :title => h(t.name))+', '}.to_s.html_safe
  end
  
  def photo_cats_links(photo)
    return '&nbsp;' if photo.photo_categories.empty?
    photo.photo_categories.collect{|c| photo_category_link(c)+', '}.to_s.html_safe
  end
  
  def photo_category_link(c)
    link_to(c.title, photo_category_path(c, :html), :title => c.title)
  end
  
  def photo_albums_links(photo)
    return '&nbsp;' if photo.photo_albums.empty?

    photo.photo_albums.collect{|t| link_to(h(t.name), photo_album_url(t,{:format => :html, :subdomain => false}), :title => h(t.name))+', '}
  end
  
  def photo_row(photo)
    row_images = Photo.find_galery_line(photo.id)
    update_photo_row(row_images.first, 'left') +
      content_tag(:ul,  row_images.collect{|p|  content_tag(:li, small_image(p, false, false) )}.to_s, :class => 'small') +
      update_photo_row(row_images.last, 'right')
  end
  
  def photo_manage(photo)
    return unless can_edit(photo)
    link_to(' ', edit_photo_path(photo), :title => 'редактировать', :class => 'ico ico-icon_settings') +
      ' ' + link_to(' ', photo, :confirm => 'Вы уверены?', :method => :delete, :title => 'удалить', :class => 'ico ico-delete') +
      ' ' + rotate_buttons(photo).html_safe
  end
  
  def rotate_buttons(photo,page = nil)
    {'anticlockwise' => 'против',  'clockwise' => 'по'}.collect{ |k,v|
      link_to('',
        photo_rotate_path(photo.id, k, page),
        :title => 'повернуть на 90 градусов '+ v +' часовой стрелке',
          :class => "ico ico-arrow_rotate_#{k}", :remote => true) + ' '
    }.to_s
  end
  
  def update_photo_row(photo, to ='right')
    link_to((to.eql?('right') ? ' ' : ' ' ),
      photo_row_path(photo.id),
      {:class => to.eql?('right') ? "nextPage #{to}" : "prevPage #{to}",
       :remote => true,
       :title => "#{to.eql?('right') ? 'следующие' : 'предыдущие' } фотографии"})
  end

  def show_photo_comment(photo)
    photo.comments.collect{|c| render_comment(photo, c) if c.is_approved || can_edit(photo) }
  end

  def render_comment(photo,c)
    content_tag(:dl,
      content_tag(:dt,
        image_tag(c.user.public_avatar, :width => 40, :alt => c.user.full_name), :class => 'w70 c' )+
        content_tag(:dd,
        link_to_user(c.user, nil, photo.user) +
          content_tag(:i, distance_of_time_in_words(Time.now(), c.created_at), :class => 'right small') +
          simple_format(sanitize(c.comment)) +
          (can_edit(photo) ? manage_comment(photo, c) : '')),
      :class => 'table paint1 w450 mt15' , :id => "comment_#{c.id}")
  end
  
  def manage_comment(photo, c)
    content_tag(:span,
      {'delete' => 'удалить',  'new' => 'разместить'}.collect{ |k,v|
        next if c.is_approved && k.eql?('new')
        link_to(v,
          photo_manage_comment_path(photo.id, k , c.id),
          :title => 'коментарий '+ v , :class => "ico ico-note_#{k}", :remote => true) + ' '
      }.to_s, :id => "manage_comment_#{c.id}")
  end
  
end