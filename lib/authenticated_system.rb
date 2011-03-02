module AuthenticatedSystem
  protected
  
  def current_user
    @current_user ||= User.find_by_id(session[:user])
  end
  
=begin
  проверка административных прав 
=end
  def is_admin?
    current_user && current_user.privilegies < 3
  end
  
  def logged_in?
    current_user ? true : false
  end
   
  def check_admin
    if current_user && current_user.privilegies == 1
      true
    else
      flash[:notice] ="You don't have access!!!"
      redirect_to(request.referer ? request.referer : '/' )
      false
    end
  end

  def check_authentificate
    unless logged_in?
      flash[:notice] = 'Доступ только для авторизированных пользователей!'#+request.inspect
      #TODO add redirect for ajax requests
      redirect_to(request.referer ? request.referer : '/')  #env["HTTP_REFERER"]
      false
      return
    end
  end
  
  def check_access(obj)
    unless can_edit(obj)
      flash[:notice] = 'У вас не достаточно привилегий!'
      redirect_to(request.referer ? request.referer : '/' )
      false
    else
      true
    end
  end
  
  def can_edit(obj)
    return false if obj.nil? || session[:user].nil?
    #logger.warn("User #{current_user.inspect} check admin #{is_admin?}")
    obj.user.id.eql?(session[:user]) || is_admin?
  end
  
  #проверка прав на возможность редактировать даные пользователя
  def can_edit_user(user)
    current_user && (current_user ==  user || is_admin?)
  end

  def rjs_check
    unless request.xhr?
      redirect_to("/")
      return false
    end
  end
  
end
