module FriendSitesHelper
  
  def site_title
    'Site title - override site_title method this in your application_helper.rb'
  end
  def site_description
    'Site Description - override site_title method this in your application_helper.rb'
  end
  include ApplicationHelper

  def site_row(site)
    content_tag(:dl,
      content_tag(:dt, (image_tag(site.button_url) unless site.button_url.blank?).to_s + 
          link_to(h(site.title), site.url, :title => site.title) +
          (is_admin? ? manage_site_links(site) : '')) +
          content_tag(:dd, h(site.description)), :class => 'pad5')
  end

  def manage_site_links(site)
    st = (site.is_active ? 'deactivate' : 'activate')
     resp = link_to(st, friend_site_activate_path(site, st)) + 
      ' | ' + link_to_remote('пров.', :url => friend_site_remote_validation_path(site)) +
      ' | ' + link_to('ред.', edit_sites_category_friend_site_path(site.sites_category_id, site)) +
      ' | ' + link_to('удал.', sites_category_friend_site_path(site.sites_category_id, site), :confirm => 'Are you sure?', :method => :delete ) 
   content_tag(:span, " [#{resp}]  #{mail_to(site.admin_email)} #{link_to(site.refered_page, site.refered_page)} ", :style => 'font-size: 80%')
  end

end
