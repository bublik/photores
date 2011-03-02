module ApplicationHelper
  include AuthenticatedSystem
  include CounterAndAdvert
  
  @@icons = {}
  alias_method :can_edit_message, :can_edit
  
  #  def msg_to_html(mesg); message_sanitize(mesg); end
  def title(text); content_for(:title){ (text.blank? ? '' : "#{h(text)} - ") + APP_CONFIG['site_name'] }; end
  def description(text); content_for(:description){ (text.blank? ? '' : "#{h(text)} - ") + APP_CONFIG['keywords'] };  end
  def keywords(text);  content_for(:keywords){ (text.blank? ? '' : "#{h(text)} - ") + APP_CONFIG['description'] }  end

  def menu_links(position = 'header')
    current_subdomain && position.eql?('header') ?
      link_to("#{@subdomain_owner.blog_title || @subdomain_owner.full_name} &nbsp;", user_root_url) :
      #link_to('Фото', photos_url(:subdomain => false)),
    [ link_to('Форум', forum_list_url(:subdomain => false)),
      link_to('Пользователи', users_url(:subdomain => false)),
      link_to('Инструкции', progect_url(:action=>'dir', :subdomain => false)),
      link_to('Статьи', wikis_url(:subdomain => false)),
      link_to('Конкурсы', contests_url(:subdomain => false)),
      link_to('Каталог ресурсов', sites_categories_url(:subdomain => false)),
      (logged_in? ? '' : link_to( t('general.registration'), new_user_url(:subdomain => false)))].join(' | ') +
      (is_admin? ? link_to( 'Управление', {:controller => '/admin/manage', :subdomain => false} ) : '')
  end

  def markitup_requirements
    javascript_include_tag('/markitup/jquery.markitup.pack.js', '/markitup/sets/html/set.js', :cache => 'markupIt') +
      stylesheet_link_tag('/markitup/skins/markitup/style.css', '/markitup/sets/html/style.css')
  end

  def rss_include(controller)
    return '' if ['users'].include?(controller)
    rss = ''
    #rss << auto_discovery_link_tag('atom', "/#{controller}.atom", {:title => "#{APP_CONFIG['site_name']} #{controller} Atom"})
    rss << auto_discovery_link_tag('rss', "/#{controller}.rss", {:title => "#{APP_CONFIG['site_name']} #{controller} Rss", :id => "gallery"}) if ['blogs', 'photos'].include?(controller)
    rss << auto_discovery_link_tag('rss', {:controller => 'messages', :action => 'rss', :id => params[:forum]}, {:title => "#{APP_CONFIG['site_name']} Rss"})
  end
  
  def contests_list
    Contest.current_konkurses.collect{|contest|
      content_tag(:div, link_to(contest.title, contest_url(contest,:html)) +
          '<br/> до финала осталось'.html_safe + distance_of_time_in_words(Time.now(), contest.date_to))
    }.to_s + content_tag(:div, link_to( 'журнал', contests_url, :class => 'small'))
  end
  
  #Установка статуса пользователей
  def user_mode(flag, h = nil)
    #/*1-admin 2-user 3-moderator */
    mode = {1 => {:text => t('general.admin'), :color => 'red'},
      2 => {:text => t('general.moderator'), :color => 'green'},
      3 => {:text => t('general.user'), :color => 'blue'},
      4 => {:text => t('general.guest'), :color => 'yellow'}}
    t('general.unknown_user'); return if mode[flag].nil?
    mode[flag]; return unless h
    content_tag(:span, mode[flag][:text], :style => "color: #{mode[flag][:color]}")
  end
   
  def hot_tags(type = 'all', order = 'count', show_type = 'block', limit = 10, title = true)
    lnks = ''
    case order
    when 'count'
      order = 'count desc'
    when 'random'
      #for postgresql
      order = 'random()' 
      #for mysql
      #order = 'rand()'
      limit = 10
    else
      order = 'tag.id'
    end

    lnks << (title ? content_tag(:h2, 'На форуме') : '')+
      Message.tag_counts(:order => order, :limit => limit).collect{|tag|
      ' ' + link_to(tag.name, tagging_url(CGI.escape(tag.name)), :class => "s#{rand(8)} #{show_type}", :rel => 'tag')}.to_s  if ['forum','all'].include?(type)
    lnks << (title ? content_tag(:h2, 'В блогах') : '')+
      Blog.tag_counts(:order => order, :limit => limit).collect{|tag|
      ' ' + link_to(tag.name, blogtag_url(CGI.escape(tag.name)), :class => "s#{rand(8)} #{show_type}", :rel => 'tag')}.to_s  if ['blog','all'].include?(type)
    lnks << (title ? content_tag(:h2, 'О фотографиях') : '')+
      Photo.tag_counts(:order => order, :limit => limit).collect{|tag|
      ' ' + link_to(tag.name, photo_tag_url(CGI.escape(tag.name)), :class => "s#{rand(8)} #{show_type}", :rel => 'tag')}.to_s  if ['photo','all'].include?(type)
    lnks
  end

  def hot_blog_tags
    content_tag(:div, content_tag(:h2, 'Теги') +
        Blog.tag_counts(:conditions => "blogs.user_id = #{@subdomain_owner.id}", :order => 'tags.id', :limit => 20).collect{|tag|
        link_to(tag.name, blogtag_path(CGI.escape(tag.name)), :title => h(tag.name), :class => "s#{rand(8)}")+ " "}.to_s, :class => 'nbg')
  end

  def hot_forum_tags
    content_tag(:div,  content_tag(:h2, 'На форуме') +
        Message.tag_counts(:order => 'count desc', :limit => 20).collect{|tag|
        link_to(tag.name, tagging_path(CGI.escape(tag.name)), :title => h(tag.name), :class => "s#{rand(8)}") + " "}.to_s, :class => 'nbg')
  end

  def controller_hot_tags(controller_name, title = true)
    case controller_name
    when 'forum'
      type = 'forum'
    when 'messages'
    when 'blogs'
      type = 'blog'
    when 'photos'
      type = 'photo'
    else
      type = 'all'
    end
    hot_tags(type, 'random', '', 30, title)
  end

  def mesg_tags(mesg)
    mesg.tags.collect{|t|  link_to(t.name, tagging_url(CGI.escape(t.name)),
        :class => 's3', :title => t.name, :rel => 'tag')}.join(', ') if (mesg.tags.length > 0) 
  end
  
  def link_to_user_blog(user, style_class = nil)
    (user && !user.blogs.empty?) ? link_to('Его блог', user_root_url(:subdomain => user.subdomain), :title => user.full_name, :rel => 'nofollow', :class => style_class) : ''
  end

  def pm_form(user_id, text = t('general.replay_priv'), css_class = 'button')
    link_to_remote(text, {:url => new_priv_message_path(:id => user_id)}, :class => css_class)
  end

  def flash_and_find(flash, contr = nil)
    logger.debug('Flash: '+flash[:notice].inspect)
    resp = ''
    resp << content_tag(:div, content_tag(:span, ' ' + image_tag('/images/loading.gif')), :id => 'jsloading', :class => 'loading', :style => 'display: none')
    resp << content_tag(:div, flash[:notice].to_s, :id => 'flash', :style => (flash[:notice].blank? ? 'display:none;' : ''))
  end

=begin
slide_show_photos_list(photos, paginate = true, login = false, editable = true)

=end
  def slide_show_photos_list(photos, paginate = true, login = false, editable = true)
    return if photos.empty?
    photo_rows = ''
    photos.in_groups_of(7, false) do |photo_row|
      photo_rows << content_tag(:ul, photo_row.collect{ |photo|
          content_tag(:li, small_image(photo, true, editable) + (login ? content_tag(:span, photo.user.login, :class => 'block') : ''), :class => 'small')}.to_s, :class => 'clear')
    end
    content_tag(:div, photo_rows, :class => 'center inline')+
      (paginate ? content_tag(:div, will_paginate(photos), :class => 'clear') : '')
  end
  
  def star_rating(rating, obj_type, id, style_class, allow_rate = true)
    per = rating > 0 ? (rating/5.0)*100 : 0;
    url_meth= "rate_#{obj_type}_path".to_sym
    if allow_rate
      links= [
        link_to_remote('1',  :url => send(url_meth, {:id => id, :rate => 1}), :html => {:class => "one-star", :title =>"1 звезды из 5"}),
        link_to_remote('2',  :url => send(url_meth, {:id => id, :rate => 2}), :html => {:class => "two-stars", :title =>"2 звезды из 5"}),
        link_to_remote('3',  :url => send(url_meth, {:id => id, :rate => 3}), :html => {:class => "three-stars", :title =>"3 звезды из 5"}),
        link_to_remote('4',  :url => send(url_meth, {:id => id, :rate => 4}), :html => {:class => "four-stars", :title =>"4 звезды из 5"}),
        link_to_remote('5',  :url => send(url_meth, {:id => id, :rate => 5}), :html => {:class => "five-stars", :title =>"5 звезды из 5"})]
    end
    r = "<div class=\"inline-rating\">  <ul class=\"#{style_class}\"> <li class=\"current-rating\" style=\"width:#{per}%;\" ></li>"
    (0..4).each{|i|  r += content_tag(:li,links[i]) } if allow_rate
    r += "</ul></div>"
    r
  end
  
  def render_rating(o, style_class = 'star-rating' )
    can_rate = logged_in? && !o.created_by?(current_user) && !o.rated_by?(current_user)
    o_type = o.class.to_s.downcase
    unless o.rated?
      star_rating(0, o_type, o.id, style_class, can_rate)
    else
      star_rating(o.rating_average, o_type, o.id, style_class, can_rate) +
        "<sup> #{o.rating_average.round(2)} из #{o.rated_count} гол.</sup>"
    end
  end

=begin
 small_image(photo, slideshow = false, is_editable = true)
=end
  def small_image(photo, slideshow = false, is_editable = true)
    manage = content_tag(:div, 
      link_to(image_tag('/images/bullet_wrench.gif'), edit_photo_path(photo), :title => 'Редактир.') +
        link_to_remote(image_tag('/images/bullet_delete.gif'),
        {:url => photo_url(photo), :method => :delete, :confirm => 'Уверен?'},
        :href => photo_url(photo), :title => 'Удалить'),
      :id => "photo_manage#{photo.id}") if is_editable && can_edit(photo)

    if slideshow
      resp = link_to(crop_image(photo), photo.public_filename(:medium),
        :title => h(photo.user.full_name+', '+photo.alt),
        :class => 'small slide').html_safe +
        content_tag(:div, link_to(truncate(h(photo.title), :length => 10), 
          photo_url(photo,  {:format => :html, :subdomain => false}),
          :title => 'перейти '+ sanitize(photo.alt.mb_chars[0..20])))
        
    else
      resp = link_to(crop_image(photo).html_safe + content_tag(:div, truncate(h(photo.title), :length => 10)),
        photo_url(photo, {:format => :html, :subdomain => false}), :title => h(photo.alt), :class => 'small')
    end
    "#{resp} #{manage}"
  end

  def crop_image(photo)
    image_tag(photo.public_filename(:crop), :alt => h(photo.alt), :id => "photo_#{photo.id}")
  end

  def crop_imagelink(photo)
    link_to(crop_image(photo), photo_url(photo, {:format => :html, :subdomain => false}), :title => h(photo.alt), :class => 'small')
  end

  def slide_block
    '<div class="simple_overlay" id="gallery" style="display: none">
    <a class="prev">prev</a> <a class="next">next</a>
    <div class="info"></div><img class="progress" src="/images/loading.gif" />
</div>'
  end
  
  def small_image_with_rate(photo, user = nil)
    rate = 0
    if photo.rated?
      rate = user ? photo.ratings.collect{|r| r.rating if r.rater_id.eql?(user.id)}.to_s.to_i : photo.rating_average 
    end
    small_image(photo, true, false) + '<br/>' + star_rating(rate, 'photo', photo.id, 'small-star', false)
  end
  
  def add_new_photo_link
    content_tag(:div, 'Добавить '+link_to('фотку', new_photo_path, :class => 'b', :rel => 'nofollow') +
        (logged_in? ? ' / '+ link_to('альбомчик', new_photo_album_path, :class => 'b', :rel => 'nofollow' ) : '.'),
      :class => 'pad5')
  end
  
  def small_profile(user,photo_albums = false)
    content_tag(:span, "#{user_avatar(user)}<br/>
    #{icq_button(user) + skype_button(user)}
    Живет: #{content_tag(:strong, user.location)}<br/>
    Сообщений: #{user.posts} <br/>
    Фотографий: #{user.photos_count} <br/>
    Рег: #{user.created_at.to_s(:short)}<br/>
    #{user_photo_albums(user) + '<br/>'.html_safe if photo_albums} ",
      :class => 'block')
  end

  def user_avatar(user)
    if logged_in?
      avatar = content_tag(:noindex, image_tag(user.public_avatar, :rel => 'nofollow', :alt => user.login, :title => user.login), :class => 'c block')
      avatar << link_to_user(user, 'block')
      unless user.eql?(current_user)
        avatar << content_tag(:span, (current_user.friends.include?(user) ? '<strong>Друг</strong>' : link_to('Дружить', new_user_friend_path(:user_id => current_user, :friend_id => user))), :class => 'block')
        avatar << link_to('Друзья', user_friends_path(user), :class => 'block')
        avatar << pm_form(user.id, 'Написать письмо', 'block')
      end
      content_tag(:div, avatar, :class => '')
    else
      content_tag(:noindex, image_tag(user.public_avatar, :alt => user.login, :rel => 'nofollow', :title => user.login)) + link_to_user(user, 'block')
    end
  end

  def photo_categories
    cnt = {}
    PhotoCategoriesPhoto.find_by_sql('select count(*) as count, photo_category_id from  photo_categories_photos group by photo_category_id').collect{|e| cnt.merge!({e.photo_category_id => e.count})}
    content_tag(:ul,
      PhotoCategory.all.collect{|c|
        content_tag(:li,
          photo_category_link(c) + ' ' +
            content_tag(:sup, cnt[c.id].to_i, :class => 'small') )}.to_s)
  end

=begin
Показываем названия альбомов и предпросмотр (4 фото)
=end
  def user_photo_albums(user, preview = false, preview_size = 4)
    unless (albums = user.photo_albums).empty?

      albums_data = albums.collect do |album|
        txt = content_tag(:h3,
          link_to(album.name, photo_album_url(album, {:format => :html, :subdomain => false}), :title => h(album.name), :class => 'clear block')) +
          content_tag(:span, "от #{album.created_at.to_s(:descr)} #{album.photos.count} работ", :class => 'small')

        if preview
          txt << content_tag(:div, content_tag(:ul, album.photos.limit(preview_size).collect{|ph| content_tag(:li, small_image_with_rate(ph, user))}.to_s))
        end
        txt
      end
      
      return content_tag(:div, content_tag(:big, 'Альбомы'), :class => 'clear') +
        content_tag(:ul, albums_data.collect{|al| content_tag(:li, al)}, :class => 'nolist')
    end
    ''
  end
  
=begin
  Рейтинги
  * Топ просмативаемых
  * Топ комментируемых
  * Топ закачиваемых
  * Кандитады на удаление
  # photo_ratings([show|download|comment|complaint])
=end
  def photo_ratings(type = nil)
    return unless type
    case type
    when 'show'
      #Топ 10 просмативаемых
      #ps = Photo.parents.this_moths.order('views DESC').limit(20)
      ps = Photo.order('updated_at DESC, views DESC').parents.limit(15)
    when 'download'
      #Топ 10 закачиваемых на этой неделе по популярности
      ps = Photo.this_moths_downloads.order('downloads DESC').parents.limit(15) #
    when 'comment'
      #последние коментированые на этой  неделе по количеству коментариев
      ps = Photo.all(:conditions => ['id IN (?)',
          Comment.photo.all(:select => :commentable_id, :group => 'commentable_id, created_at', :limit => 15, :order => 'created_at DESC').collect(&:commentable_id)])
      #ps = Photo.parents.order('comments_count DESC').limit(20) #.this_moths_comments
    when 'complaint'
      #максимальне колличество жалоб к этим фотографиям
      ps = Photo.parents.top_complaints.limit(4)
    end
    ps.empty? ? '<!-- no data-->' : content_tag(:ul, ps.collect{|p| content_tag(:li, small_image(p, false, false))} )
  end
  
  #Последние 10 постов в блогах
  def blog_last_posts(limit = 15)
    @blog_posts = Blog.paginate(:all,
      :conditions => (@subdomain_owner ? ['user_id = ?', @subdomain_owner] : []),
      :limit => limit, :include => [:user],
      :order => 'created_at DESC', :page => params[:page])
    @blog_posts.collect do |b|
      div_for(b, :class => 'pad5') do
        concat link_to(h(b.title), blog_url(b, {:format => :html, :subdomain => b.user.subdomain}), :class=> 'block')
        concat truncate(strip_tags(b.body), :length => 40)
        concat user_and_time_distance(b)
      end
    end
  end
  #Последние 10 постов на форуме
  def forum_last_posts(limit = 15)
    Message.topics.all(:limit => limit, :order => 'updated_at DESC', :include => [:user]).collect do |m|
      div_for(m, :class => 'pad5') do
        concat link_to( h(m.name), message_path(m), :class => 'block', :title => h(m.name))
        concat truncate(strip_tags(m.message), :length => 40)
        concat user_and_time_distance(m)
      end
    end
  end

  def last_photo_comments(limit = 15, size = 40)
    Comment.approved.last_comments('Photo', limit).collect do |coment|
      div_for(coment, :class => 'pad5') do
        text = (size ? sanitize(coment.comment).mb_chars[0..size] : sanitize(coment.comment))
        content_tag(:div, link_to(text, photo_path(coment.photo, :html), :title => sanitize(coment.photo.alt))) + user_and_time_distance(coment)
      end
    end
  end
  
  def last_activity(limit = 15)
    User.activity(limit).collect do |user|
      div_for(user, :class => 'pad5') do
        concat content_tag(:strong, user.full_name)+ ' / '
        concat content_tag(:span, distance_of_time_in_words(Time.now(), user.last_activity_at) + ' тому ', :class => 'small') 
        concat content_tag(:div, user.last_activity)
      end
    end
  end

  def site_activity
    ptoday = Photo.parents.today.count
    utoday = User.today.count
    altoday = PhotoAlbum.today.count
    ctoday = Comment.ptoday.count
    mtoday = Message.today.count
    btoday = Blog.today.count
    wtoday = Wiki.today.count
    content_tag(:div) do
      content_tag(:h3, 'У нас уже') +
        content_tag(:div, "Пользователей: #{User.count}"+ (utoday > 0 ? "(<span class='red'>+#{utoday}</span>)" : '')) +
        content_tag(:div, "Фотографий: #{Photo.parents.count}" + (ptoday > 0 ? "(<span class='red'>+#{ptoday}</span>)" : '')) +
        content_tag(:div, "Альбомов: #{PhotoAlbum.count}"+ (altoday > 0 ? "(<span class='red'>+#{altoday}</span>)" : '')) +
        content_tag(:div, "Коментариев: #{Comment.count} к фото"+ (ctoday > 0 ? "(<span class='red'>+#{ctoday}</span>)" : '')) +
        content_tag(:div, "На форуме: #{Message.count} сообщ."+ (mtoday > 0 ? "(<span class='red'>+#{mtoday}</span>)" : '')) +
        content_tag(:div, "Записок: #{Blog.count} в блогах"+ (btoday > 0 ? "(<span class='red'>+#{btoday}</span>)" : '')) +
        content_tag(:div, "Статей: #{Wiki.count}"+ (wtoday > 0 ? "(<span class='red'>+#{wtoday}</span>)" : ''))
    end
  end

  ####################################################
  def footer(controller = nil)
    #Add google analytics code
    menu =  content_tag(:div, bigmir_counter, :class => 'c') + '<!-- footer menu -->'.html_safe
    unless current_subdomain
      sape = show_sape_links(3)
      menu << (sape.blank? ? '' : content_tag(:div, "Реклама: #{sape}", :class => 'menu'))
      menu << content_tag(:div, controller_hot_tags(controller, false), :class => 'pad5') unless params[:action].eql?('index')
    end
    menu << content_tag(:div,'Права на все фотографии принадлежат их авторам. Использование работ в комерческих целях без согласия автора - запрещено!<br/>
      Использование материалов разрешено с активной ссылкой на страницу с оригиналом.')
    menu << content_tag(:div, menu_links('footer'), :class => 'menu') unless current_subdomain
    menu << content_tag(:div, link_to(APP_CONFIG['site_name'],progect_url(:action=>'about', :subdomain => false)) +' : '+
        mail_to("Voloshin Ruslan <rebisall@gmail.com>", "Контакты", :encode => "hex"), :class => 'small menu')
    content_tag(:div, menu.html_safe, :id => 'footer', :class => 'clear')
  end

  ################STATIC#########################
  #Get online user from DB
  def online
    whos_online = Array.new(); guests = 0; users = 0
    onlines = ActiveRecord::SessionStore::Session.find(:all, :conditions => ['updated_at > ?', Time.now.utc()-10.minutes])
    ActiveRecord::SessionStore::Session.delete_all(['updated_at < ?', Time.now() - 7.days])
    guests = onlines.size
    onlines.each do |online|
      unless online.data[:user].nil?
        whos_online << link_to_user(User.find_by_id(online.data[:user]))+', '
        users += 1
      end
    end
    content_tag(:div, t('general.guests_online')+ " #{guests - users} " +
        t('general.users_online') + (users.eql?(0) ? '0' : whos_online.uniq.join(' ')))
  end

  def msg_icon
    return @@icons  unless  @@icons.empty?
    i = 0
    dir = Dir["#{RAILS_ROOT}/public/images/icons/*{gif,jpg,jpeg,png}"]
    dir.sort.each {|file| @@icons[i += 1] = '/images/icons/'+file.split('/').pop }
    return @@icons
  end

  def banner_advert
    return '<script type="text/javascript"><!--
google_ad_client = "ca-pub-1004778522513778";
/* 180-90-block-links */
google_ad_slot = "3489303896";
google_ad_width = 180;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>'
  end

  def google_adv_row
    '<script type="text/javascript"><!--
google_ad_client = "ca-pub-1004778522513778";
/* fotosites-728-15-links */
google_ad_slot = "5426964844";
google_ad_width = 728;
google_ad_height = 15;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>'
  end
  
  def privatbank
    '<big>Услуги Приватбанка</big>
<script src="https://partner.privatbank.ua/wv1.js" type="text/javascript" charset="UTF-8" partner_main_id="9861683826" chanalname="null" chanalcomment="null"></script>'
  end
end
