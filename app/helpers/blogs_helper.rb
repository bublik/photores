module BlogsHelper
  def render_blog_msg(blog, tag = nil)
    post = content_tag(:h2, link_to( blog.title, blog_path(blog,:html)), :class => 'pad5 forum')
    post += content_tag(:div, render_rating(blog), :class => 'grey', :style => 'display: inline', :id => "rate_#{blog.id}")

    post += content_tag(:div,
      content_tag(:span, blog.created_at.to_s(:db), :class => 'ico ico-date') + ' ' +
        content_tag(:span, "#{blog.bcomments.count} коммент.".html_safe, :class => 'comment') +
        (can_edit(blog) ?
          content_tag(:span, link_to(t('general.edit'), edit_blog_path(blog), :class => 'ico ico-page_edit', :title => t('general.edit')) + ' ' +
            link_to(t('general.delete'), blog, :title => t('general.delete'), :class => 'ico ico-page_delete', :confirm => 'Are you sure?', :method => :delete)) : ''),
      :class => 'small pad5')

    post += content_tag(:div, blog.body, :class => 'pad5')
    post += content_tag(:div, image_tag('/images/ico/tag_blue.gif', :align=>'bottom') +
        blog.tags.collect{|t|
        link_to(t.name, {:controller => 'blogs', :action => 'tag', :id => t.name},
          :class=>'tforum', :title=>t.name, :rel=>'tag')}.join(', ').html_safe,
      :class => 'pad5')
  end
end
