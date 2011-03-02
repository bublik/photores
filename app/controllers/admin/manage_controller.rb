class Admin::ManageController < ApplicationController
  before_filter  :check_admin 
  
  def index
    #defalt page for admin
  end

  def mail_new
    #render for m for send mail to users
  end

  def mail_send
    msg = params[:mail]['message']
    if msg && params[:mail]['test'].eql?('0')
      flash[:notice] = 'Send mails to all users.'
      User.find(:all).each do |u|
        Mailer.deliver_system_msg(u, msg)
      end
    else
      flash[:notice] = 'Send test email to me.'
      Mailer.deliver_system_msg(current_user, msg)
    end
    redirect_to :action => 'index'
  end
  
  def destroy_inactiv_users
    User.destroy_all(['active = ? ', false])
    flash[:notice] = 'Не активные пользователи удалены.'
    redirect_to :action => 'index'    
  end
  
  def db_optimization
    if params[:start]
      case ActiveRecord::Base.establish_connection.config[:adapter]
      when 'mysql'
        ActiveRecord::Base.connection.select_rows("show tables").each do  |table|
          ActiveRecord::Base.connection.execute("OPTIMIZE TABLE #{table} ")
        end
      when 'postgres'
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Base.connection.execute("VACUUM #{table};  REINDEX table")
        end
      else
        # ничего не делать
      end
      flash[:notice] = 'База ортимизирована.'
    end
    redirect_to :action => 'index'
  end
end
