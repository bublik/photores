module WikisHelper

  def manage_links(wiki)
    return '' unless wiki
    can_edit(wiki) ? link_to('Изменить', edit_wiki_path(wiki), :class => 'small') + ' / ' +
      link_to('Удалить', wiki, :confirm => 'Are you sure?', :method => :delete, :class => 'small') : ''
  end
  
  def tags_lis(wiki = nil, style = nil )
    return '' if !wiki || wiki.tag_list.blank?
    content_tag(:div, 'Теги: ' +
        wiki.tag_list.split(Tag.delimiter).collect{|tag| link_to(tag, wiki_tag_path(tag), :title => tag)}.join(', '),
      :class => "pad5 #{style}")
  end

  def create_by(wiki, style = nil)
    return '' unless wiki
    content_tag(:div, 'Доб. ' +
        link_to_user(wiki.user) + ' / ' + wiki.created_at.to_s(:db) + ' / '+
        manage_links(wiki),
      :class => "small pad5 #{style}")
  end
end
