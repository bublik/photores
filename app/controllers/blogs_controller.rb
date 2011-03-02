class BlogsController < ApplicationController
  # GET /blogs
  # GET /blogs.xml
  before_filter :check_authentificate, :only => [:new, :create]
  before_filter :init_blog, :only => [ :show, :edit, :update, :destroy ]
  before_filter :check_access, :only => [:edit, :update, :destroy ]
  
  def index
    if ['atom', 'rss'].include?(params[:format]) && current_subdomain.nil?
      redirect_to('/', :status => 301)
      return
    end

    if current_subdomain.nil?
      @blogs = Blog.all(:limit => 15, :order => 'ID DESC', :include => 'user')
      render :action => :list
    else
      @blogs = @subdomain_owner.blogs.paginate(:all, :order => 'created_at DESC', :include => [:bcomments, :user, :tags], :page => params[:page])

      respond_to do |format|
        format.html # index.html.erb
        format.xml { render :xml => @blogs }
        format.atom do
          headers['Content-Type'] = 'application/atom+xml; charset=utf-8'
          render :action => 'atom', :layout => false
        end
        format.rss do
          headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
          render :action => 'rss', :layout => false
        end
      end
    end
  end

  def list

  end
  
  def tag
    @tag = CGI.unescape(params[:id].to_s)
    @blogs = Blog.find_tagged_with(@tag, :conditions => ['user_id = ?', @subdomain_owner.id]).paginate(:page => params[:page], :include => [:user])
    #@posts = Post.paginate(Post.find_tagged_with(params[:tag_name]), :page => params[:page])
    return redirect_to(:action => :index) if @blogs.empty? 
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @blogs }
      format.atom do
        headers['Content-Type'] = 'application/atom+xml; charset=utf-8'
        render :action => 'atom', :layout => false
      end
    end
  end
  # GET /blogs/1
  # GET /blogs/1.xml
  def show
    return redirect_to(:action => :index) if @blog.nil?
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog }
    end
  end
  
  # GET /blogs/new
  # GET /blogs/new.xml
  def new
    @blog = Blog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog }
    end
  end

  # GET /blogs/1/edit
  def edit
    
  end

  # POST /blogs
  # POST /blogs.xml
  def create
    @blog = Blog.new(params[:blog])
    @blog.user = current_user
    respond_to do |format|
      if @blog.save
        flash[:notice] = 'Новое сообщение добавлено.'
        format.html { redirect_to(@blog) }
        format.xml  { render :xml => @blog, :status => :created, :location => @blog }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blogs/1
  # PUT /blogs/1.xml
  def update
    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        flash[:notice] = 'Сообщение сохранено!'
        format.html { redirect_to(@blog) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.xml
  def destroy
    @blog.destroy

    respond_to do |format|
      format.html { redirect_to(blogs_url) }
      format.xml  { head :ok }
    end
  end

  def rate
    @post = Blog.find(params[:id])
    @post.rate(params[:rate].to_i, current_user)

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
      format.js {}
    end
  end

  protected
  def init_blog
    unless (@subdomain_owner && @blog = @subdomain_owner.blogs.find(params[:id].to_i))
      redirect_to("http://#{APP_CONFIG['domain']}/", :status => 301)
      flash[:notice] = 'Такого сообщения нет или оно удалено.'
      return
    end
  end
  
  def check_access
    unless can_edit(@blog)
      flash[:notice] = 'У вас не достаточно привилегий!'
      redirect_to(:action => 'index')
      return
    end
  end
  
end
