class FriendSitesController < ApplicationController
  before_filter :load_category

  # GET /friend_sites
  # GET /friend_sites.xml
  def index
    redirect_to(sites_category_path(@category))
    return
    #    @friend_sites = @category.friend_sites.find(:all)
    #
    #    respond_to do |format|
    #      format.html # index.html.erb
    #      format.xml  { render :xml => @friend_sites }
    #    end
  end

  # GET /friend_sites/1
  # GET /friend_sites/1.xml
  def show
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @friend_site }
    end
  end

  # GET /friend_sites/new
  # GET /friend_sites/new.xml
  def new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @friend_site }
    end
  end

  # GET /friend_sites/1/edit
  def edit
    @friend_site = @category.friend_sites.find(params[:id])
    render :action => 'new'
  end

  # POST /friend_sites
  # POST /friend_sites.xml
  def create
    @friend_site = @category.friend_sites.new(params[:friend_site])
    #Admin should be can add new resourses without validation back links for promote own site

    @friend_site.remote_check = false if is_admin?
    
    respond_to do |format|
      if @friend_site.save
        flash[:notice] = 'Ваш сайт доабвлен в каталог.'
        if is_admin?
          @friend_site.update_attribute('is_active', true)
          flash[:notice] += 'И активирован.'
        end
        #        format.html { redirect_to(@friend_site) }
        format.html {redirect_to(sites_category_path(@category))}
        format.xml  { render :xml => @friend_site, :status => :created, :location => @friend_site }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @friend_site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /friend_sites/1
  # PUT /friend_sites/1.xml
  def update
    @friend_site = @category.friend_sites.find(params[:id])

    respond_to do |format|
      if @friend_site.update_attributes(params[:friend_site])
        flash[:notice] = 'Данные о сайте обновлены.'
        #        format.html { redirect_to(@friend_site) }
        format.html {redirect_to(sites_category_path(@category))}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @friend_site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /friend_sites/1
  # DELETE /friend_sites/1.xml
  def destroy
    @friend_site.destroy

    respond_to do |format|
      format.html { redirect_to(sites_category_path(@category)) }
      format.xml  { head :ok }
    end
  end
  
  def activation
    unless is_admin?
      flash[:notice] = 'У вас нет прав!'
      redirect_to('/')
      return
    end

    @friend_site.update_attribute('is_active', params[:state].eql?('activate'))    
    respond_to do |format|
      flash[:notice] = "Акивация сайта - #{@friend_site.is_active}"
      format.html { redirect_to(sites_category_path(@friend_site.sites_category_id)) }
    end
  end
  
  def remote_validation
    flash[:notice] = ''
    unless is_admin?
      flash[:notice] = 'У вас нет прав!'
      redirect_to('/')
      return
    end
    @friend_site.remote_validation
    if @friend_site.errors.empty?
      flash[:notice] = 'Сайт активирован.'
    else
      @friend_site.errors.each_full {|msg| flash[:notice] += msg + "<br/>"}
    end
    @friend_site.save
    respond_to do |format|
      #    format.html { redirect_to(sites_category_path(@category)) }
      format.js
    end
  end
  
  private
  def load_category
    @friend_site = params[:id] ? FriendSite.find(params[:id]) : FriendSite.new
    @category = SitesCategory.find(params[:sites_category_id]) if params[:sites_category_id]
  end
end
