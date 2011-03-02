class BcommentsController < ApplicationController
  before_filter :load_post
  before_filter :check_comment_access, :only => [:edit, :update, :destroy ]
  before_filter :check_authentificate, :only => [:create, :new]
  
  # GET /bcomments
  # GET /bcomments.xml
  def index
    @bcomments = @blog.bcomments.find(:all)

    respond_to do |format|
      format.html { render :partial =>'index', :locals => {:blog => @blog, :bcomments => @bcomments}} # index.html.erb
      format.xml  { render :xml => @bcomments }
    end
  end

  # GET /bcomments/1
  # GET /bcomments/1.xml
  def show
    @bcomment = @blog.bcomments.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bcomment }
    end
  end

  # GET /bcomments/new
  # GET /bcomments/new.xml
  def new
    @bcomment = @blog.bcomments.build
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bcomment }
    end
  end

  # GET /bcomments/1/edit
  def edit
    @bcomment = @blog.bcomments.find(params[:id])
  end

  # POST /bcomments
  # POST /bcomments.xml
  def create
    @bcomment = Bcomment.new(params[:bcomment])
    @bcomment.user = current_user
    @blog.bcomments << @bcomment
    #logger.debug(@bcomment.inspect)   
    respond_to do |format|
      if @blog.save
        flash[:notice] = 'Коментарий добавлен.'
        format.html { redirect_to(@blog) }
        format.xml  { render :xml => @bcomment, :status => :created, :location => @bcomment }
      else
        format.html { redirect_to(@blog) }
        format.xml  { render :xml => @bcomment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bcomments/1
  # PUT /bcomments/1.xml
  def update
    @bcomment = @blog.bcomments.find(params[:id])

    respond_to do |format|
      if @bcomment.update_attributes(params[:bcomment])
        flash[:notice] = 'Коментарий сохранен.'
        format.html { redirect_to(@blog) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bcomment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bcomments/1
  # DELETE /bcomments/1.xml
  def destroy
    @bcomment = @blog.bcomments.find(params[:id])
    @bcomment.destroy

    respond_to do |format|
      format.html { redirect_to(@blog) }
      format.xml  { head :ok }
    end
  end
  
  def load_post
    @blog = Blog.find(params[:blog_id])
  end
  
  def check_comment_access
    check_access(@blog)
  end
end
