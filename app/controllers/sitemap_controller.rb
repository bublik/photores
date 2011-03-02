class SitemapController < ApplicationController
  caches_action :xml, :expires_in => 2.days
  
  def xml
    unless @subdomain_owner
      @forums = Forum.find(:all)
      @messages = Message.find(:all, :order => "updated_at DESC", :limit => 2500)
      @photos = Photo.parents.find(:all, :order => "updated_at DESC", :limit => 2500)
      @blogs = []
      @last_updated = [@photos[0].updated_at, @messages[0].updated_at].max
    else
      @forums = @messages = []
      @blogs = @subdomain_owner.blogs.find(:all, :order => "updated_at DESC", :limit => 25000)
      @photos = @subdomain_owner.photos.parents.find(:all, :order => "updated_at DESC", :limit => 2500)
      @last_updated = (@photos.first || @blogs.first || @subdomain_owner).updated_at
    end

    headers["Content-Type"] = "text/xml"
    headers["Last-Modified"] = @last_updated.httpdate
    render :layout => false
  end
end
