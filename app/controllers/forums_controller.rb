class ForumsController < ApplicationController

  def index
    redirect_to(:action => 'list')
  end

  before_filter  :check_admin, :only => [ :create, :destroy, :update, :edit,:new, :split]

  def list
    @forums = Forum.paginate(:all, :order => "fgroup_id ASC, sort ASC,name ASC", :page => params[:page] )
    if is_admin?
      @groups = Fgroup.all
    else
      @groups = Fgroup.vissible.all
    end
  end

  def show
    @forums = Forum.find(params[:id])
  end

  def new
    @forums = Forum.new
  end

  def create
    @forums = Forum.new(params[:forums])
    if @forums.save
      flash[:notice] = t('general.forum_created')
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @forums = Forum.find(params[:id])
  end

  def update
    @forums = Forum.find(params[:id])
    if @forums.update_attributes(params[:forums])
      flash[:notice] = t('general.forum_updated')
      redirect_to :action => 'show', :id => @forums
    else
      render :action => 'edit'
    end
  end

  def destroy
    @forum=Forum.find(params[:id])
    #delete all messages from forum
    Message.find(:all,:conditions => ["forum_id = ?", @forum.id]).each{|msg| msg.destroy}
    @forum.destroy
    redirect_to :action => 'list'
  end
  
  def split
    f = params[:forum]
    if f[:from_id] && f[:to_id]
      logger.debug(f[:from_id])
      logger.debug(f[:to_id])
      from = Forum.find(f[:from_id])
      if from && from.split_forums(f[:to_id])
        flash[:notice] = 'Разделы объединены.'
      else
        flash[:notice] = 'Ошибка при объединении разделов.'
      end
    else
      flash[:notice] = 'Incorrect from or to forum ID.'
    end
    redirect_to('/')
  end

end
