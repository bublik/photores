class Admin::CameraBrandsController < ApplicationController
  before_filter  :check_admin

  # GET /camera_brands
  # GET /camera_brands.xml
  def index
    @camera_brands = CameraBrand.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @camera_brands }
    end
  end

  # GET /camera_brands/1
  # GET /camera_brands/1.xml
  def show
    @camera_brand = CameraBrand.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @camera_brand }
    end
  end

  # GET /camera_brands/new
  # GET /camera_brands/new.xml
  def new
    @camera_brand = CameraBrand.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @camera_brand }
    end
  end

  # GET /camera_brands/1/edit
  def edit
    @camera_brand = CameraBrand.find(params[:id])
  end

  # POST /camera_brands
  # POST /camera_brands.xml
  def create
    @camera_brand = CameraBrand.new(params[:camera_brand])

    respond_to do |format|
      if @camera_brand.save
        flash[:notice] = 'CameraBrand was successfully created.'
        format.html { redirect_to(@camera_brand) }
        format.xml  { render :xml => @camera_brand, :status => :created, :location => @camera_brand }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @camera_brand.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /camera_brands/1
  # PUT /camera_brands/1.xml
  def update
    @camera_brand = CameraBrand.find(params[:id])

    respond_to do |format|
      if @camera_brand.update_attributes(params[:camera_brand])
        flash[:notice] = 'CameraBrand was successfully updated.'
        format.html { redirect_to(@camera_brand) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @camera_brand.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /camera_brands/1
  # DELETE /camera_brands/1.xml
  def destroy
    @camera_brand = CameraBrand.find(params[:id])
    @camera_brand.destroy

    respond_to do |format|
      format.html { redirect_to(camera_brands_url) }
      format.xml  { head :ok }
    end
  end
end
