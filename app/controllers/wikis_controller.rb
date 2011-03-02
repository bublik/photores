class WikisController < ApplicationController
  layout 'index'
  before_filter :session_check, :only => [ :destroy, :create, :new, :edit, :update]
  before_filter :init_wiki, :only => [ :destroy, :show, :edit, :update]

  # GET /wikis
  # GET /wikis.xml
  def index
    @wikis = Wiki.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wikis }
    end
  end

  # GET /wikis/1
  # GET /wikis/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @wiki }
    end
  end

  # GET /wikis/new
  # GET /wikis/new.xml
  def new
    @wiki = Wiki.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wiki }
    end
  end

  # GET /wikis/1/edit
  def edit
  end

  # POST /wikis
  # POST /wikis.xml
  def create
    @wiki = Wiki.new(params[:wiki])
    @wiki.user = current_user

    respond_to do |format|
      if @wiki.save
        upload_process
        flash[:notice] = 'Wiki was successfully created.'
        format.html { redirect_to(@wiki) }
        format.xml  { render :xml => @wiki, :status => :created, :location => @wiki }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wiki.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /wikis/1
  # PUT /wikis/1.xml
  def update
    respond_to do |format|
      if @wiki.update_attributes(params[:wiki])
        upload_process
        flash[:notice] = 'Wiki was successfully updated.'
        format.html { redirect_to(@wiki) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wiki.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /wikis/1
  # DELETE /wikis/1.xml
  def destroy
    @wiki.destroy

    respond_to do |format|
      format.html { redirect_to(wikis_url) }
      format.xml  { head :ok }
    end
  end

  def preview
    render :partial => 'preview'
  end
  
  ################Find tags list#################
  def tag
    @search_tag  = CGI.unescape(params[:tag_name].to_s)
    @wikis = Wiki.find_tagged_with(@search_tag).paginate(:page => params[:page])
    if @wikis.empty?
      flash[:notice]  =  'Несуществующий тег!'
      redirect_to('/')
      return
    end
  end


  private
  def init_wiki
    @wiki = Wiki.find(params[:id])
  end

  def upload_process
    if upload_data = params[:file]
      upload_data.keys.each do |img_id|
        @wiki.attachments << Attachment.new(:uploaded_data => params[:file][img_id], :user => current_user)
      end
    end
  end
  
  def session_check
    unless logged_in?
      flash[:notice] = t('general.notice_register_add_msg')
      redirect_to(root_path)
    end
    logged_in?
  end

end
