class PhotosController < ApplicationController
  caches_action :photo_row, :cache_path => Proc.new { |controller| controller.params.to_s}, :expires_in => 1.hour

  before_filter :check_authentificate, :only => [ :destroy, :update, :create, :new,
    :rate, :rotate, :manage_comment, :add_note]
  before_filter :init_photo, :only => [ :show, :edit, :update, :destroy, :photo_row,
    :rate, :rotate, :add_comment, :manage_comment, :complaint, :download, :static_link, :add_note, :show_notes]
  before_filter :have_access?, :only => [ :destroy, :update, :rotate, :manage_comment]
  
  # GET /photos
  # GET /photos.xml
  def index
    @user = params[:user_id].nil? ? nil : User.find_by_login(params[:user_id])
    @photos = @user.nil? ? Photo.parents.limit(15) : @user.photos
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photos }
      format.atom do
        #  headers['Content-Type'] = 'application/atom+xml; charset=utf-8'
        render :action => 'atom', :layout => false
      end
      format.rss do
        #     headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
        render :action => 'rss', :layout => false
      end
    end
  end

  # GET /photos/1
  # GET /photos/1.xml
  def show
    unless search_bots
      @photo.show_at = Time.now
      @photo.increment!(:views, 1)
    end
    
    google_map_settings(@photo, false)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { 
        # @photo[:thumb] = @photo.public_filename(:thumb)
        render :xml => @photo.to_xml(:skip_types => true)}
    end
  end

  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = Photo.new
    @cats = PhotoCategory.all
    @photo.photo_category_ids = session[:liked_photo_categories] ||= []
    google_map_settings(@photo, true)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @cats = PhotoCategory.all
    google_map_settings(@photo, true)
    return unless check_access(@photo)
  end

  # POST /photos
  # POST /photos.xml
  def create 
    params[:photo][:photo_category_ids] ||= []
    session[:liked_photo_categories] = params[:photo][:photo_category_ids]
    @photo = Photo.new(params[:photo])
    @photo.current_state = :added
    @photo.user = current_user
    respond_to do |format|
      if @photo.save
        flash[:notice] = 'Новая фотография добавлена.'
        format.html { redirect_to(photo_path(@photo)) }
        format.xml  { render :xml => @photo, :status => :created, :location => @photo }
      else
        @cats = PhotoCategory.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    unless check_access(@photo)
      redirect_to(photos_url)
      return 
    end
    
    respond_to do |format|
      @photo.current_state = :changed
      if @photo.update_attributes(params[:photo])
        flash[:notice] = 'Информация о фотографии обновлена.'
        format.html { redirect_to(@photo) }
        format.xml  { head :ok }
      else
        @cats = PhotoCategory.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    unless check_access(@photo)
      redirect_to(photos_url);
      return
    end
    
    flash[:notice] = "Фотография <strong>#{@photo_id}</strong> удалена!"
    @photo.current_state = :delete
    @photo.destroy
    
    respond_to do |format|
      format.html { redirect_to(photos_url)}
      format.xml  { head :ok }
      format.js  { }
    end
  end
  
  def rate
    rating = params[:rate].to_i
    @photo.current_state = :vote 
    @photo.rate(rating, current_user)
    @photo.save

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
      format.js {}
    end
  end
  
  def tag
    @photos = Photo.find_tagged_with(params[:tag_name]).paginate(:order => 'updated_at DESC', :include => [:user], :page => params[:page])
    if @photos.empty?
      flash[:notice]  =  'Несуществующий тег!'
      redirect_to(photos_path) 
      return
    end
  end

  def photo_row
    respond_to do |format|
      format.html { redirect_to @photo }
      format.js  { }
    end
  end
  
  def rotate
    if ['anticlockwise', 'clockwise'].include?(params[:to])
      @photo.rotate(params[:to]) 
    else
      flash[:notice] = 'Не корректные параметры!'
    end
    respond_to do |format|
      format.html { redirect_to @photo }
      format.js  { }
    end
  end

  def add_note
    unless request.post?
      redirect_to(photo_path(@photo))
      return
    end

    note = PhotoNote.new(params['data']['Note'])
    note.user = current_user
    note.photo = @photo
    
    if note.save
      flash[:notice] = 'Ваша аннотация добавлена!'
    else
      flash[:error] = note.errors.full_messages.to_sentense
    end
    
    redirect_to(photo_path(@photo))
  end

  def show_notes
    respond_to do |format|
      format.json { render :text => @photo.photo_notes.collect(&:json_attr).to_json}
    end
  end

  def add_comment
    if params[:comment] && logged_in?
      @comment = Comment.new(params[:comment])
      @comment.user = current_user
      @comment.is_approved = @photo.auto_approve
    else
      @comment = Comment.new
      @comment.user = User.new
    end
    
    respond_to do |format|
      session[:last_photo_comment] ||= Time.now
      format.html { 
        if request.post?
          @photo.add_comment(@comment)
          session[:last_photo_comment] = Time.now
          @photo.update_attribute(:comment_at, Time.now)
          flash.now[:notice] = 'Ваш коментарий активируется после проверки автором.' unless @photo.auto_approve
          redirect_to photo_path(@photo)
        else
          render :partial => 'comment_form', :layout => 'index'
        end
      }
      format.js {
        logger.debug('render RJS')
        unless params[:comment]
          render :update do |page|
            if logged_in?
              page.replace_html 'comments_form',  :partial => 'comment_form'
              logger.debug('RENDER FORM')
            else
              page.replace_html 'comments_form', content_tag(:div, "Доступ только для зарегистрированных пользователей / #{link_to( t('general.registration'),new_user_path)}", :class => 'b', :id => 'waiting_approve')
            end
          end
          return
        end
        
        if session[:last_photo_comment] > (Time.now - 10.seconds)
          render :update do |page|
            page.insert_html :before, 'comments_form', '<div class="b">Комментарии можно добавлять не чаще чем раз в 10 секунд.</div>'
          end
          return
        end
        if @comment.valid? && @photo.add_comment(@comment)
          session[:last_photo_comment] = Time.now
          @photo.update_attribute(:comment_at, Time.now)
          flash.now[:notice] = 'Ваш коментарий активируется после проверки автором.' unless @photo.auto_approve
          logger.debug('SAVE FORM')
        else
          render :update do |page|
            page.insert_html :before, 'comments_form', '<div class="b">'+@comment.errors.full_messages.join('<br/>')+'</div>'
          end
          return
        end
      }
    end
  end

  def manage_comment
    logger.debug('Manage Photo')
    @cid = params[:comment_id]
    @comment = Comment.find(@cid)
    #      ''; return unless @comment
    case params[:change_to]
    when 'new'
      @comment.update_attribute(:is_approved, true)
    when 'delete'
      @comment.destroy
    else
      flash.now[:notice] = 'Не известное дейтвие'
    end
    respond_to do |format|
      format.html {redirect_to photo_path(@photo, :html)}
      format.js {}
    end
  end
  
  def photo_vote_list
    @user = User.find(params[:id])
    @user ||= current_user
    return redirect_to('/') unless @user
    #    @messages  =  Photo.paginate(:all,
    #      :conditions => ['photo.id IN (?)', Photo.find_rated_by(@user)],
    #      :order   => 'created_at DESC',  :page   => params[:page])
    @rated_list = Photo.find_rated_by(@user)
    @photos  =  @rated_list.paginate(:order => 'created_at DESC', :page => params[:page])
  end

  def complaint
    unless logged_in?
      flash[:notice] = 'Данная функция вам не доступна. Для продолжения зарегистрируйтесь.';
      redirect_to(new_user_path)
      return
    end
    
    session[:last_complaint] ||= Time.now
    if session[:last_complaint] + 5.minutes < Time.now
      @photo.current_state = :complaint
      @photo.save
      if @photo.complaint.eql?(10)
        @photo.destroy
        #Сбрасываем счетчиик времени для завершающего пользователя
        session[:last_complaint] = nil
        flash[:notice] = 'Фотография была удаленя из за получения максимального колличества  жалоб.'
        redirect_to :action => 'index'
        return
      end
      session[:last_complaint] = Time.now
      flash[:notice] = 'Ваша жалоба будет рассмотрена в ближайшее время.'
    else
      flash[:notice] = 'Извините но так часто жаловаться нельзя. Возможно у вас скверный характер?'
    end
    redirect_to(@photo)
  end

  def download
    if logged_in? || simple_captcha_valid?
      send_file @photo.full_filename, :disposition => 'attachment'
      @photo.download_at = Time.now
      @photo.increment!(:downloads, 1)
    elsif params[:captcha]
      flash[:notice] = 'Зашитный код не верный'
    end
  end

  #Пoиск фотографий по цветам
  def colors
    @color = session[:color] = (params[:color].to_s.empty? ? '882729' : params[:color])
    logger.debug("COLOR #{@color}")
    @photos = Photo.find_by_color(@color, {:page => params[:page], :per_page => 30})

    respond_to do |format|
      format.html { }
      #      format.js { }
    end
  end
  
  protected
  def init_photo
    @photo = Photo.find(params[:id].to_i)
    logger.debug("PHOTO: ==========> "+@photo.inspect)
    redirect_to(photo_path(@photo.parent, :html), :status => 301) and return unless @photo.is_parent?
    unless @photo
      flash[:notice] = 'Такой фотографии нет.'
      redirect_to(photos_path)
      return
    end
  end

  def have_access?
    check_access(@photo)
  end

  def google_map_settings(photo, dragable = true)
    if !dragable && !photo.new_record? && (photo.lat.blank? || photo.lng.blank?)
      @map = nil
      return
    end
    
    @map = GMap.new("map_div_id")
    @map.control_init(:large_map => true, :map_type => true)

    if photo.new_record?
      location = Geocoders::MultiGeocoder.geocode(Rails.env.eql?('development') ? '91.196.95.33' : request.remote_ip)
    else
      location = photo# = [photo.lat, photo.lng]
    end
    position = (location.lat.blank? || location.lng.blank?) ?
      [46.46773395387448, 30.740582942962646] :
      [location.lat, location.lng]

    @map.center_zoom_init(position, 7)
    #    var mylabel = {"url":"overlay.png",
    #                  "anchor":new GPoint(4,4),
    #                  "size":new GSize(12,12)};
    #   var Icon = new GIcon(G_DEFAULT_ICON, "marker.png", mylabel);
    #    @map.icon_global_init(GIcon.new(:image => "/images/map/icon46.png",
    #        #:shadow => "/images/pizza-shadow.png",
    #        :shadow_size => GSize.new(37,32),
    #        :icon_anchor => GPoint.new(7,7),
    #        :info_window_anchor => GPoint.new(9,2)), "photo_icon")

    # photo_icon = Variable.new("photo_icon")

    @marker = GMarker.new(position,
      # :icon => photo_icon,
      :draggable => dragable,
      :title => dragable ? 'перетащите к месту съемки' : 'место съемки')#,:info_window => 'Установите место для фотографии')
    @map.overlay_global_init(@marker, "photo_marker")
    @map.overlay_init(@marker)
    @map.event_init(@marker, 'dragend',
      "function(){
var pos = photo_marker.getLatLng();
$('#photo_lat').attr('value', pos.lat());
$('#photo_lng').attr('value', pos.lng());}")

    #$.ajax({type: 'POST', url: '#{url_for(:controller => 'photos', :action => 'store_position')}', data: '' });

  end
end