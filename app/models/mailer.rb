class Mailer < ActionMailer::Base

  def user_activate(user)
    setup(user)
    @subject    = I18n.t('general.mail_aply_register')
  end
  
  def change_password(user)
    setup(user)
    @subject    = I18n.t('general.mail_change_password')
  end

  def reminde_password(user)
    setup(user)
    @subject    = I18n.t('general.mail_reminde_password')
  end
  
  #отправка письма о подписке
  def notice(user,msg)
    setup(user)
    @subject     = I18n.t('general.mail_describe_msg')
    @body['msg'] = msg
  end
  #отправка письма подписанным на тему на форуме
  def new_post(user,msg)
    setup(user)
    @subject     = I18n.t('general.mail_new_msg')
    @body['msg'] = msg
  end
  

  def new_photo_comment(user, photo)
    setup(user)
    @subject       = I18n.t('general.mail_new_comment') + " - " + APP_CONFIG['site_name']
    @body['photo'] = photo
  end
  
  def new_privatemsg(user, msg)
    setup(user)
    @subject    = I18n.t('general.mail_new_privatemsg')
    @body['priv_message'] = msg
  end
  
  def system_msg(user, msg)
    setup(user)
    @subject     = 'Информация с '+APP_CONFIG['domain']
    @body['msg'] = msg
  end
  
  protected
  def setup(user)
    @recipients = user.email
    @from       = 'Форум '+APP_CONFIG['site_name']+' <'+APP_CONFIG['admin_email']+'>'
    @sent_on    = Time.now
    headers    = {}
    @body['user'] = user
  end
end