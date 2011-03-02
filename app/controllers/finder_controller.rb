class FinderController < ApplicationController
  #protect_from_forgery  :except => :find
  skip_before_filter :verify_authenticity_token
 
  def find
    @type = params[:ftype]
    page = params[:page]
    @result = []
    
    begin
      case @type
      when 'messages'
        @result = Message.search(params[:search_word], :per_page => 10, :page => page)
      when 'photos'
        @result = Photo.search(params[:search_word], :per_page => 30, :page => page) # Photo.parents.paginate(:all, :limit => 10, :page => params[:page])
      when 'blogs'
        @result = Blog.search(params[:search_word], :per_page => 10, :page => page)
      end
    rescue Exception => ex
      flash[:notice] = t('flash.search_daemon_halt')
      ExceptionNotifier.deliver_exception_notification(ex, self, request)
      redirect_to(root_url)
    end
    if @result.empty?
      flash[:notice] = 'Result empty!'
      redirect_to(root_url(:subdomain => false))
    end
  end  
end
