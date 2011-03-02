class LoginController < ApplicationController

  def index
    render :action => 'login'
  end
  
  before_filter  :rjs_check, :only => [:check_reactivate,:repassword]
  
  #TODO
  #1. add function reactivate password
  #2. pass_reset запросить ссылку для изменения пароля
  
  def login
    @site_title = t('general.auth')
    respond_to do |format|
      format.js   { render }
      format.html { render :partial => 'login' }
    end
  end
  
  
  def form_reactivate
    #render form 
  end
  
  def check_reactivate
    @user = User.find(:first,:conditions=>['login = ?', params[:user][:login]])

    unless @user.nil?
      Mailer.deliver_user_activate(@user)
      flash[:notice] = t('general.mail_link_send')
    else
      flash[:notice] = t('general.notice_user_unknown')
    end
    
    respond_to do |format|
      format.html  { redirect_to(root_url) }
      format.js   { render }
    end
  end

  
  def activate
    #Активизируем акаунт
    @user = User.find(:first, :conditions => [ "code_activate = ?", params[:id]])
    unless @user.nil?
      session[:user] = @user.id
      @user.activate!
      flash[:notice] = t('general.notice_account_activated')
      redirect_to( :controller => 'forums', :action => 'index')
    else
      flash[:notice] = t('general.notice_error_activated')
      redirect_to(:action => 'login')
    end
    
  end
  
  def form_repassword
    #render form for reminde password
  end
  
  def repassword
    req = params[:user]
    @user = User.find(:first, :conditions => ['login = ? OR email = ? ',req['login'], req['email']])
    unless @user.nil?
      Mailer.deliver_reminde_password(@user)
      flash[:notice] = t('general.mail_link_send')
    else
      flash[:notice] = t('general.notice_user_unknown')
    end
  
    respond_to do |format|
      format.html  { redirect_to(root_url) }
      format.js   { render }
    end

  end
  
=begin
/login/auth?login=userlogin&password=user_password

  Respond
 XML
 Logged in [ auth = OK , user_id = '12']
 Login failed [auth = 'Failed', description = 'description for failed']
=end
  def auth
    session[:referer] = request.env['HTTP_REFERER'] if request.env['HTTP_REFERER']
    userparams = params[:user]
    @user = User.auth(userparams[:login],userparams[:password])
    #
    respond_to do |format|
      if @user.nil?
        logger.debug("User not found")
        #login failed
        flash[:notice] = t('general.login_password_not_found')
        format.js { }
        format.xml { render :xml => {:auth => 'Failed', :description => flash[:notice]}.to_xml }
        format.html {redirect_to(:action=>'login')}
      elsif @user && !@user.active
        logger.debug("User is not active")
        flash[:notice] = t('general.user_not_activated')
        format.js { }
        format.xml { render :xml => {:auth => 'Failed', :description => flash[:notice]}.to_xml }
        format.html {redirect_to(:action=>'login')}
      else
        #loged in
        session[:user] = @user.id
        logger.debug(session.inspect)
        @user.update_attribute(:updated_at, Time.now)
        format.js {}
        format.xml { render :xml => {:auth => 'OK', :user => @user}.to_xml }
        format.html {redirect_to(session[:referer] || '/')}
      end
    end
                                                                                                                                                                            
  end
  
  def logout
    reset_session
    session[:user] = nil
    flash[:notice] = t('general.notice_logout')
    respond_to do |format|
      format.js   { render }
      format.html {redirect_to(session[:referer] || '/')}
    end
    #    redirect_to(:controller=>'forums',:action=>'list')
  end
  
end
