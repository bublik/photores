class UsersController < ApplicationController
  
  def index
    list
    render :action => 'list'
  end
  
  before_filter :user_can_edit, :only => [ :destroy, :update, :edit,:change_avatar,
    :change_password,:private_messages,:edit_signature,:edit_attachment]

  def list
    @users = User.active.paginate(:page => params[:page], :order => 'updated_at DESC')
  end
  
  def show
    @user = current_subdomain ?
      @subdomain_owner :
      User.find(params[:id], :include => [:friendships => :friend])
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @user.to_xml(current_user) }
    end
    return redirect_to('/') if @user.nil?
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])    
    if  @user.valid_with_captcha? && @user.valid? #@user.valid?# && @user.valid_with_captcha?
      @user.save
      flash[:notice] = t('general.notice_user_created')
      #Send email for activate user
      Mailer.deliver_user_activate(@user)
      redirect_to '/'
    else
      render :action => 'new'
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      @notice = t('general.content_updated')
      flash[:notice] = t('users.flash.profile_updated')
    else
      @notice = t('general.content_updated_error')
    end
    render :action => 'edit', :id => @user
  end
  
  
  def destroy
    User.find(params[:id]).destroy if is_admin?
    flash[:notice] = t('general.notice_user_droped')
    redirect_to :action => 'list'
  end
  ##########################manage profiles#########################
  def edit
    return recirect_to('/')  unless user_can_edit
    @user = params[:id] ? User.find(params[:id]) : current_user
    if @user.nil?
      flash[:notice] = t('users.flash.user_not_found')
      redirect_to('/')
      return
    end
  end
  
  def change_avatar
    #Аватар/Фото
    render :layout => false if request.xhr?
  end
  
  def save_avatar
    #Аватар/Фото
    if params[:private_avatar].eql?('destroy') && current_user.private_avatar.id.eql?(params[:private_avatar_id].to_i)
      @state = 'Avatar deleted!'
      current_user.private_avatar.destroy
      current_user.private_avatar.reload
    else
      if current_user.private_avatar
        current_user.private_avatar.destroy
        current_user.private_avatar.reload
      end
      if current_user.update_attribute(:avatar, params[:avatar])
        @state = t('general.avatar_updated')
      else
        @state = t('general.avatar_updated_error')
      end
    end
    respond_to do |format|
      format.js { render } 
    end
  end
  
  def upload_avatar
    if !params[:avatar] || params[:avatar][:uploaded_data].blank?
      flash[:notice] =  t('users.flash.avatar_not_selected');
      redirect_to  :action => 'change_avatar', :id => current_user
      return
    end
    user = current_user
    avatar = (user.private_avatar ?  user.private_avatar : PrivateAvatar.new)
    avatar.uploaded_data = params[:avatar][:uploaded_data]
    avatar.user = user
    if avatar.valid?
      avatar.save
    else
      flash[:notice] =  avatar.errors.collect{|n,v|  "#{n} - #{v}<br/>" }.to_s
    end
    redirect_to(:action => 'change_avatar', :id => user.id)
  end
  
  def change_password
  end
  
  def save_password
    #Пароль
    unless user_can_edit
      @state = t('general.notice_permissions_denie')
      return
    end
    #НАчало проверки данных
    user = params[:users]
    if current_user[:password] != user[:password]
      @state = t('general.current_password_incorrect')
      return
    end
    if user[:re_password].blank? && user[:new_password].eql?(user[:re_password])
      current_user.password = user[:new_password]
      current_user.crypt_password = User.md5(user[:new_password])
      if current_user.valid?
        current_user.save
        Mailer.deliver_change_password(current_user)
        @state = t('general.current_password_updated')
      else
        @state = t('general.content_incorrect')
      end
    else
      @state = t('general.passwords_different')
    end
    respond_to do |format|
      format.js { render } 
    end
  end

  def widget
    
  end
  #Личные сообщения
  def private_messages
    @pmsg = current_user.get_priv_messages
    respond_to do |format|
      format.js { render }
      format.html
    end
  end

  def read_private_messages
    @pmsg = current_user.get_priv_messages.find(params[:id])
    flash[:notice] = 'Сообщение помечено как прочитанное.'
    @pmsg.toggle!(:read)
    respond_to do |format|
      format.js { render }
    end
  end

  def delete_private_messages
    @read_pmsg = PrivMessage.find(params[:id], :conditions => ['to_user_id =?', current_user.id])
    
    unless @read_pmsg.nil? 
      @hide_id = @read_pmsg.id
      @read_pmsg.destroy
      flash[:notice] = t('general.notice_message_deleted')
    else
      flash[:notice] = t('general.notice_permissions_denie')
    end
    respond_to do |format|
      format.js 
    end

  end
  
  def edit_attachment
    respond_to do |format|
      format.js { render} 
      format.html {}
    end
  end
  
  #проверка прав на  редактирование профайла пользователя
  def user_can_edit
    if current_user && (is_admin? || params[:id] ? current_user.id == params[:id].to_i : false)
      true
    else
      flash[:notice] = t('general.notice_permissions_denie')
      redirect_to '/'
      false
    end
  end
end
