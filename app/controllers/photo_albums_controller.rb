class PhotoAlbumsController < ApplicationController
  before_filter :check_authentificate, :only => [ :destroy, :update, :create, :edit, :new]
  before_filter :init_photo_albums, :only => [ :show, :edit, :update, :destroy]
  before_filter :have_access?, :only => [ :destroy, :update, :edit]
  
  # GET /photo_albums
  # GET /photo_albums.xml
  def index
    unless @user = User.first(:conditions => {:id => params[:user_id].to_i})
      redirect_to(root_url)
      return
    end
    
    @photo_albums =  @user.photo_albums 
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photo_albums }
    end
  end

  # GET /photo_albums/1
  # GET /photo_albums/1.xml
  def show
    
    respond_to do |format|
      format.html # show.html.erb
      #  format.xml  { render :xml => {'album' => @photo_album.photos.first.inspect}}
      format.xml  { render :xml => {'album' => @photo_album, 'photos' => @photo_album.photos}.to_xml(:root => 'photo-album', :skip_types => true)}
    end
  end

  # GET /photo_albums/new
  # GET /photo_albums/new.xml
  def new
    @photo_album = PhotoAlbum.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @photo_album }
    end
  end

  # GET /photo_albums/1/edit
  def edit
    @user = params[:user_id].nil? ? nil : User.find(params[:user_id])
  end

  # POST /photo_albums
  # POST /photo_albums.xml
  def create    
    
    respond_to do |format|
      @photo_album = current_user.photo_albums.build(params[:photo_album])
      if @photo_album.save
        flash[:notice] = 'Новый альбом создан.'
        format.html {
          #          if current_user.photo_albums.size > 1
          #          redirect_to(@photo_album)
          #          else
          redirect_to(new_photo_path)
          #          end
        }
        format.xml  { render :xml => @photo_album, :status => :created, :location => @photo_album }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo_album.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photo_albums/1
  # PUT /photo_albums/1.xml
  def update

    respond_to do |format|
      if @photo_album.update_attributes(params[:photo_album])
        flash[:notice] = 'PhotoAlbum was successfully updated.'
        format.html { redirect_to(@photo_album) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo_album.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_albums/1
  # DELETE /photo_albums/1.xml
  def destroy
    @photo_album.destroy

    respond_to do |format|
      format.html { redirect_to(photo_albums_url) }
      format.xml  { head :ok }
    end
  end
  
  protected 
  def init_photo_albums
    @photo_album = PhotoAlbum.find_by_id(params[:id].to_i)
    unless @photo_album
      flash[:notice] = "Такого альбома нет."
      redirect_to(photos_path)
      return
    end
  end
  
  def have_access?
    check_access(@photo_album)
  end
end
