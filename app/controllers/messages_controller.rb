class MessagesController < ApplicationController
  layout 'index', :except => [:rss]
  require 'resolv'

  before_filter :session_check, :only => [ :destroy, :create, :new,:replay, :edit,:update ,:send_replay_priv]

  def index
    redirect_to('/')
    return
  end

  ############# LIST ##########################
  def list
    @forum = Forum.find(params[:forum])
    return redirect_to('/') if @forum.nil?

    @messages  =  @forum.messages.topics.paginate(
      :order   => 'stickunstick DESC, updated_at DESC',
      :include => [:user, :tags],  :page   => params[:page])
  end

  def user_msg_list
    @user = User.find(params[:id])
    return redirect_to('/') unless @user

    @messages = @user.messages.paginate(:order => 'created_at DESC', :page => params[:page])
  end

  def user_vote_list
    @user = User.find(params[:id])
    return redirect_to('/') unless @user
    @messages = Message.find_rated_by(@user).paginate(:order => 'created_at DESC', :page => params[:page])
  end

  ################Find tags list#################
  def tag
    @search_tag  = CGI.unescape(params[:tag_name].to_s)
    @posts = Message.find_tagged_with('Funny, Silly').paginate(:order => 'stickunstick DESC, updated_at DESC', :page => params[:page])

    if @posts.empty?
      flash[:notice]  =  'Несуществующий тег!'
      redirect_to('/')
      return
    end
  end

  ###########Show last messages################
  def last_posts
    @messages = Message.paginate(
      :conditions => 'parent_id IS NULL',
      :order => "updated_at DESC",
      :page => params[:page])
  end

  ###########Last messages ask RSS################
  def rss
    unless params[:id].nil?
      @messages = Message.find(:all,{
          :conditions => ['forum_id = ?', params[:id]],
          :limit => 10,
          :order => 'id DESC'
        })
    else
      @messages = params[:topics].eql?('new') ?
        Message.topics.all({:limit => 10, :order => 'id DESC'}) :
        Message.all({:limit => 10, :order => 'id DESC'})
    end
    respond_to do |format|
      format.xml
    end
  end

  ################ SHOW ########################
  def show
    unless @message = Message.find(params[:id], :include => [:user, :tags])
      flash[:notice] = 'Page not found.'
      redirect_to('/')
      return
    else
      Message.increment_counter(:views, @message.id)
      render( :layout => 'clear') if params[:layout].eql?('none')
    end
  end

  def show_ip
    @message = Message.find(params[:id])
    begin
      @remote_name = Resolv.getname(@message.ip)
    rescue Exception  => e # Resolv::ResolvError: cannot interpret as address:
      @remote_name = "Error: #{e.message}"##{e.backtrace.inspect}
    end
    if params[:layout].eql?('none')
      render( :layout => 'clear')
    end
  end


  ############## NEW #######################
  def new
    return redirect_to( '/', flash) unless !params[:forum].nil?

    @forum_id = params[:forum]
    @forum = Forum.find(@forum_id)
    @message = Message.new
  end
  ############## Replay #######################
  def replay
    return redirect_to( '/', flash) unless !params[:forum].nil? || !params[:id].nil?
    @to_replay = Message.find(params[:id])
    @message = Message.new

    respond_to do |format|
      format.html {
        if @to_replay.openclose.eql?(1)
          flash[:notice] = t('general.notice_message_slosed')
          redirect_to(:back, flash)
          return
        end
      }
      format.js {
        render :update do |page|
          page.replace_html 'replay_block', :partial => 'replay', :locals => {:message => @message, :to_replay => @to_replay}
          page.delay(2) do
            page[:replay_block].visual_effect :highlight
          end
        end
      }
    end
  end

  ############# CREATE ########################
  def create
    unless !params[:message][:forum_id].nil?
      redirect_to( '/', flash)
      return
    end

    @message = Message.new(params[:message])
    @message.user = current_user
    @message.ip = request.remote_ip
    if upload_data = params[:file]
      upload_data.keys.each do |img_id|
        @message.attachments << Attachment.new(:uploaded_data => params[:file][img_id], :user => current_user)
      end
    end
    if @message.save
      flash[:notice] = t('general.notice_msg_created')
      flash[:notice] = 'Ваш ответ добавлен.' if !@message.parent_id.nil?
      redirect_to({:action =>'show', :id => @message.parent_id || @message.id}, flash)
    else
      flash[:notice] = t('general.notice_message_empty')
      unless params[:message][:parent_id].nil?
        redirect_to({:action => 'show', :id => params[:message][:parent_id]}, flash)
        return
      end
      redirect_to(:back)
    end
    return
  end

  ############## EDIT #############################
  def edit
    @message = Message.find(params[:id])
    return redrect_to('/') unless @message
    can_edit_message(@message)
    expire_fragment(@message.cache_key)
  end

  ############## UPDATE ########################
  def update
    @message  =  Message.find(params[:id])
    return redrect_to('/') unless @message
    can_edit_message(@message)

    if @message.update_attributes(params[:message])
      #Add uploaded files
      params[:file].keys.each do |img_id|
        @message.attachments << Attachment.new(:uploaded_data => params[:file][img_id], :user => current_user)
      end if params[:file]
    
      flash[:notice] = t('general.notice_msg_updated')
      unless @message.parent_id.nil?
        redirect_to({ :action => 'show', :id => @message.parent_id})
        return
      end
      redirect_to({:action => 'show', :id => @message})
    else
      render({:action => 'edit'})
    end
  end
  ############## DESTROY ####################
  def destroy
    @mesg = Message.find(params[:id])
    return redrect_to(:back) unless @mesg

    can_edit_message(@mesg)
    @mesg.destroy
    flash[:notice] = t('general.message')+" #{@mesg.name} "+ t('general.droped')
    redirect_to(list_messages_path(:forum => @mesg.forum_id), flash )
  end

  def rate
    @message = Message.find(params[:id])
    rating= params[:rate].to_i
    @message.rate(rating, current_user)

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
      format.js {}
    end
  end

  def preview
    render :partial => 'preview'
  end
  ##################PRIVATE SECTION##########
  private

  def can_edit_message(msg)
    if logged_in? && (can_edit(msg) || current_user.is_admin_or_moderator?)
      return true
    else
      flash[:notice] = t('general.notice_permissions_denie')
      redirect_to(:action => 'list', :forum => @msg.forum_id)
    end
  end

  def session_check
    unless logged_in?
      flash[:notice] = t('general.notice_register_add_msg')
      redirect_to(root_path)
    end
    logged_in?
  end

  def ping(messages)
    keywords = APP_CONFIG['keywords'].split(',').collect{|word| "#{word}|"}
    p = Pinging.new( APP_CONFIG['site_name'], url_for( :host => APP_CONFIG['domain']),
      url_for( :host => APP_CONFIG['domain'], :controller =>'messages', :action  =>'show', :id => messages.id),
      url_for( :host => APP_CONFIG['domain'], :controller =>'messages', :action  =>'rss', :id => messages.forum_id),
      keywords)
    p.ping_all
  end

end

