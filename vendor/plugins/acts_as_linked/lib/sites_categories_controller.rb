class SitesCategoriesController < ApplicationController
  # GET /sites_categories
  # GET /sites_categories.xml
  def index
    @sites_categories = SitesCategory.find(:all, :order => 'name ASC')
    @waiting_sites = FriendSite.not_active.all if is_admin?

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites_categories }
    end
  end

  # GET /sites_categories/1
  # GET /sites_categories/1.xml
  def show
    @sites_category = SitesCategory.find(params[:id])
    if is_admin? && params[:active].eql?('false')
      @sites = @sites_category.friend_sites.not_active.paginate(:page => params[:page])
    else
      @sites = @sites_category.friend_sites.active.paginate(:page => params[:page])
    end
    # logger.debug(@sites.inspect)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sites_category }
    end
  end

  # GET /sites_categories/new
  # GET /sites_categories/new.xml
  def new
    @sites_category = SitesCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sites_category }
    end
  end

  # GET /sites_categories/1/edit
  def edit
    @sites_category = SitesCategory.find(params[:id])
  end

  # POST /sites_categories
  # POST /sites_categories.xml
  def create
    @sites_category = SitesCategory.new(params[:sites_category])

    respond_to do |format|
      if @sites_category.save
        flash[:notice] = 'SitesCategory was successfully created.'
        format.html { redirect_to(@sites_category) }
        format.xml  { render :xml => @sites_category, :status => :created, :location => @sites_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sites_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sites_categories/1
  # PUT /sites_categories/1.xml
  def update
    @sites_category = SitesCategory.find(params[:id])

    respond_to do |format|
      if @sites_category.update_attributes(params[:sites_category])
        flash[:notice] = 'SitesCategory was successfully updated.'
        format.html { redirect_to(@sites_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sites_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites_categories/1
  # DELETE /sites_categories/1.xml
  def destroy
    @sites_category = SitesCategory.find(params[:id])
    @sites_category.destroy

    respond_to do |format|
      format.html { redirect_to(sites_categories_url) }
      format.xml  { head :ok }
    end
  end
end
