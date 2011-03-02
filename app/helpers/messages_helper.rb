module MessagesHelper

  def msg_status(box)
    {'openclose' => t('general.openclose'), 'stickunstick' => t('general.stickunstick')}[box]
  end

  #Генерация ссылки ФОРУМ/РАЗДЕЛ
  def top_forum_link(forum,msg)
    link = [link_to(h(APP_CONFIG['site_name']), {:controller => 'forums', :action => 'list'}, :class => 'tforum')]
    link << link_to(h(forum.name), list_messages_path( :forum => forum.id),
      :title => forum.name, :class => 'tforum') if forum
    unless msg.to_s.empty?
      link << link_to(msg.parent.name, message_path(msg.parent, :forum => msg.forum_id),
        :title => msg.parent.name, :class => 'tforum') unless msg.parent.nil?
      link << link_to(msg.name, message_path(msg, :forum => msg.forum_id),
        :title => msg.name, :class => 'tforum')
    end
    link.join(' / '.html_safe)
  end
  
  def messages_top_links(mesg, locked = false)
    mlinks = ''  
    return mlinks unless logged_in?
    if can_edit_message(mesg)
      mlinks << link_to(t('general.edit'), {:controller=>'messages',:action=>'edit',:id => mesg}, :class=>'button-edit')
      mlinks << link_to(t('general.delete'), {:controller=>'messages',:action=>'destroy',:id => mesg}, :class=>'button-delete', :confirm => "Are you sure?")
    end
    mlinks << link_to(t('general.replay'), {:controller=>'messages',:action=>'replay',:id=>mesg,:forum=>mesg.forum_id}, :class=>'button-edit') if !locked
    mlinks << '&nbsp;'
    mlinks << link_to('IP', {:controller=>'messages', :action=>'show_ip',:id=>mesg.id}, :title=>mesg.ip) if is_admin?
    mlinks 
  end
  
  def show_edition(message, show_bookmarks = false)
    content_tag(:div,
      link_to('назад', {:action => 'list', :forum =>message.forum}, :title => t('general.back'), :class => 'back_msg')+' ' +
        (logged_in? ?
        link_to('новый' ,  {:action => 'new', :forum =>message.forum},  :title => t('general.new'), :class => 'ico ico-page_sound')+' ' +
        link_to('ответить', {:action => 'replay', :id => message , :forum => message.forum }, :title => t('general.replay'), :class => 'replay_msg') : ''),
      :class => 'pad5')
    #        (show_bookmarks ?  '<!-- AddThis Button BEGIN -->
    #<script type="text/javascript">addthis_pub  = \'bublik\'; addthis_brand = \''+APP_CONFIG['domain']+'\'; </script>
    #<a rel="nofollow" href="http://www.addthis.com/bookmark.php" onmouseover="return addthis_open(this, \'\', \'[URL]\', \'[TITLE]\')" onmouseout="addthis_close()" onclick="return addthis_sendto()"><img src="http://s9.addthis.com/button1-bm.gif" width="125" height="16" border="0" alt="" /></a><script type="text/javascript" src="http://s7.addthis.com/js/152/addthis_widget.js"></script>
    #<!-- AddThis Button END -->' : '')
  end
end
