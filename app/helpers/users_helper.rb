module UsersHelper
  @@list = []
  #Список аватар в директории

  def link_to_user(user, style_class = nil, rel = nil)
    rel_text = rel.nil? ?  '' : xfn_rel_tag(rel, user)
    user ? link_to(user.full_name, user_root_url({:subdomain => user.subdomain},:html),
      :title=> user.full_name,
      :class=> style_class.to_s + (rel_text.blank? ? '' : ' xfnRelationship ') + "#{' red ' if user.privilegies.eql?(1)}",
      :rel => rel_text
    ) : 'guest'
  end

  def profile_menu
    content_tag(:div,
      content_tag(:h2, t('general.profile_manage')) +
        content_tag(:div,
        link_to_if(is_admin?, 'Администрирование', {:controller => '/admin/manage'}, :class => 'orange') +
          link_to('Фото Виджет', user_widget_path(current_user), :class => 'orange block') +
          link_to(t('general.user_info'), edit_user_path(current_user), :class => 'block') +
          link_to(t('general.photo_albums'), user_photo_albums_path(current_user), :class => 'block') +
          link_to(t('general.photo_profile'), photo_profiles_path, :class => 'block') +
          link_to(t('general.avatar'), {:controller => 'users', :action => 'change_avatar',:id => current_user}, :class => 'block') +
          link_to(t('general.private_messages'), {:controller => 'users', :action => 'private_messages', :id => current_user}, :class => 'block') +

          link_to(t('general.frends'), user_friends_path(current_user)) +
          link_to('Оцененные фотографии', photo_vote_path(current_user), :class => 'block') +
          link_to('Оцененил на форуме', user_votes_url(current_user, :subdomain => false), :class => 'block') +
          link_to(t('general.messages'), user_messages_url(current_user, :subdomain => false), :class => 'block') +

          link_to(t('general.attachments'),  {:controller => 'users', :action => 'edit_attachment', :id => current_user}, :class => 'block')) +
        link_to(t('general.change_password'), {:controller => 'users', :action => 'change_password', :id => current_user}, :class => 'block'),
      :class => 'pad5 mr15 left w200 border')
  end
  
=begin
== user_and_time_distance(obj)
 bublik/ около 9 дней
=end
  def user_and_time_distance(obj)
    content_tag(:div, content_tag(:b, obj.user.full_name) + ' / ' + 
        distance_of_time_in_words(Time.now(), obj.updated_at), :class => 'small')
  end

  def icq_button(user)
    return '' if user.icq_number.blank?
    content_tag(:noindex,
      link_to(image_tag("http://status.icq.com/online.gif?img=5&amp;icq=#{user.icq_number}", :alt => "#{user.full_name} #{user.icq_number}"), 'http://www.icq.com/whitepages/about_me.php?uin='+user.icq_number.to_s, :title => "#{user.full_name} #{user.icq_number}" ) + user.icq_number.to_s,
      :class => 'block')
  end

  def skype_button(user)
    return '' if user.skype_name.blank?
    content_tag(:noindex, '<script type="text/javascript" src="http://download.skype.com/share/skypebuttons/js/skypeCheck.js"></script>
<a href="skype:'+user.skype_name+'?call"><img src="http://download.skype.com/share/skypebuttons/buttons/call_blue_transparent_70x23.png" style="border: none;" width="70" height="23" alt="Skype Me™!" /></a>',
      :title =>  "Skype: #{user.skype_name}", :class => 'block')
  end
  
  #TODO add possibility user make private avatar
  def avatar_list
    return @@list unless @@list.empty?
    @dir = Dir["#{Rails.root}/public/"+APP_CONFIG['avatars_dir']+"/*{gif,jpg,jpeg,png}"]
    @dir.sort.each {|file|  @@list << APP_CONFIG['avatars_dir']+file.split("/").pop   }
    return @@list
  end
    
  def xfn_rel_tag(user, user_to)
    return '' unless user_to
    friendship = user_to.friendships.find_by_friend_id(user.id)
    return '' if friendship.nil?
    return 'me' if user.id.eql?(user_to.id)
    
    friendship.attributes.collect{|att, val|
      att.sub(/xfn_/,'').sub(/^co/,'co-') if att.match(/xfn/) && val
    }.compact.join(' ')
  end
  
end
