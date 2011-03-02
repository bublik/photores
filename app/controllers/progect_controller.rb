class ProgectController < ApplicationController

  def index
    clear_old_sessions if is_admin?
    @forums = Forum.find(:all,:order => "sort ASC,name ASC")
    @messages  = Message.paginate(:all, 
      :conditions   =>'parent_id IS NULL', 
      :order => "updated_at DESC", 
      :page => params[:page], :per_page => '10')
    f = Forum.find(:first, :conditions => ["description like ?",'%новости%'])
    @news = f.lastmsg if f
  end
  
  def help
  end

  def about
  end

  def dir
    #render links to other sites
    @files = Dir["#{RAILS_ROOT}/public/doc/*.*"].collect{|file| file.split('/').last }
  end

  def group
  end

  def mobile
    
  end
end
