class PrivMessagesController < ApplicationController
  before_filter :logged_in?, :only => [ :destroy, :create, :new, :show, :edit,:update ]

  # GET /priv_messages
  # GET /priv_messages.xml
  def index
    unless is_admin?
      redirect_to('/')
      return
    end
    
    @priv_messages = PrivMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @priv_messages }
    end
  end

  # GET /priv_messages/1
  # GET /priv_messages/1.xml
#  def show
#    @priv_message = PrivMessage.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @priv_message }
#    end
#  end

  # GET /priv_messages/new
  # GET /priv_messages/new.xml
  def new
    session[:msg_to] = nil
    @user = User.find(params[:id])
    @user.nil? ? flash[:notice] = t('general.notice_user_id_incorrect') : session[:msg_to] = @user.id

    @priv_message = PrivMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @priv_message }
      format.js
    end
  end

  #  # GET /priv_messages/1/edit
  #  def edit
  #    @priv_message = PrivMessage.find(params[:id])
  #  end

  # POST /priv_messages
  # POST /priv_messages.xml
  def create
    respond_to do |format|
      format.js {
        msg = params[:priv_message]
        if msg && msg[:data].empty?
          flash[:notice] = t('general.notice_message_empty')
          return
        end

        return flash[:notice] = t('general.notice_permissions_denie') if session[:msg_to].nil?
        msg = PrivMessage.new(:to_user_id => session[:msg_to], :data => msg[:data], :title => "#{t('general.from')}: #{current_user.full_name}")

        if msg.valid?
          @to_user = User.find(session[:msg_to])
          current_user.priv_messages << msg
          Mailer.deliver_new_privatemsg(@to_user, msg)
          flash[:notice] = t('general.notice_message_sended')
          session[:msg_to] =  nil
          return
        end
        flash[:notice] = t('general.notice_message_sende_err')
      }
    end
    
    #    @priv_message = PrivMessage.new(params[:priv_message])
    #
    #    respond_to do |format|
    #      if @priv_message.save
    #        flash[:notice] = 'PrivMessage was successfully created.'
    #        format.html { redirect_to(@priv_message) }
    #        format.xml  { render :xml => @priv_message, :status => :created, :location => @priv_message }
    #      else
    #        format.html { render :action => "new" }
    #        format.xml  { render :xml => @priv_message.errors, :status => :unprocessable_entity }
    #      end
    #    end
  end

#  # PUT /priv_messages/1
#  # PUT /priv_messages/1.xml
#  def update
#    @priv_message = PrivMessage.find(params[:id])
#
#    respond_to do |format|
#      if @priv_message.update_attributes(params[:priv_message])
#        flash[:notice] = 'PrivMessage was successfully updated.'
#        format.html { redirect_to(@priv_message) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @priv_message.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

#  # DELETE /priv_messages/1
#  # DELETE /priv_messages/1.xml
#  def destroy
#    @priv_message = PrivMessage.find(params[:id])
#    @priv_message.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(priv_messages_url) }
#      format.xml  { head :ok }
#    end
#  end
end
