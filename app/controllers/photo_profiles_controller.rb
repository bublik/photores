class PhotoProfilesController < ApplicationController

  before_filter :check_authentificate, :only => [ :destroy, :update, :create, :new]
  before_filter :init_profile, :only => [ :show, :edit, :update, :destroy]
  before_filter :have_access?, :only => [ :destroy, :update]

  # GET /photo_profiles
  # GET /photo_profiles.xml
  def index
    @photo_profiles = current_user.photo_profiles

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photo_profiles }
    end
  end

  # GET /photo_profiles/1
  # GET /photo_profiles/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo_profile }
    end
  end

  # GET /photo_profiles/new
  # GET /photo_profiles/new.xml
  def new
    @photo_profile = PhotoProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo_profile }
    end
  end

  # GET /photo_profiles/1/edit
  def edit

  end

  # POST /photo_profiles
  # POST /photo_profiles.xml
  def create
    @photo_profile = current_user.photo_profiles.build(params[:photo_profile])

    respond_to do |format|
      if @photo_profile.save
        flash[:notice] = 'Фото профайл успешно  создан.'
        format.html { redirect_to(photo_profiles_url) } #redirect_to(@photo_profile)
        format.xml  { render :xml => @photo_profile, :status => :created, :location => @photo_profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo_profile.errors, :status => :unprocessable_entity }
      end
    end
    
    
  end

  # PUT /photo_profiles/1
  # PUT /photo_profiles/1.xml
  def update
    respond_to do |format|
      if @photo_profile.update_attributes(params[:photo_profile])
        flash[:notice] = 'Фото профайл обновлен.'
        format.html { redirect_to(photo_profiles_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_profiles/1
  # DELETE /photo_profiles/1.xml
  def destroy
    @photo_profile.destroy
    flash[:notice] = 'Фото профайл удален.'
    respond_to do |format|
      format.html { redirect_to(photo_profiles_url) }
      format.xml  { head :ok }
    end
  end
  
  protected 
  def init_profile
    @photo_profile = current_user.photo_profiles.find(params[:id])
    unless @photo_profile
      flash[:notice] = "Такого профайла нет."
      redirect_to(photos_path)
      return
    end
  end
  
  def have_access?
    check_access(@photo_profile)
  end
end
