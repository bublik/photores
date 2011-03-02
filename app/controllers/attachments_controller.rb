class AttachmentsController < ApplicationController
  before_filter  :rjs_check, :only => [:destroy]
  
  def index
    flash[:notice] = 'Да нет тут нифига!'
    redirect_to('/')
    return
  end
  
  def destroy
    atach = Attachment.find(params[:id])
    if atach.nil? || !can_edit?(atach)
      flash[:notice] = 'У вас нет прав для редактирования этого файла!'
      return
    end
    @destroy = atach.destroy ? flash.now[:notice] = 'File deleted!' :  flash.now[:notice] = 'File is not deleted!'
    #@last_attachments = atach.attachable.attachments
    respond_to do |format|
      format.js   { render } 
    end
  end


=begin
Show or download attached file
=end
  def show
    atach = Attachment.find(params[:id])
    atach.is_image? ?
      redirect_to(attach.public_filename) :
      send_file( Rails.public_path+atach.public_filename, :filename => atach.filename, :type => atach.content_type)
  end
  
  private
  def can_edit?(atach)
    (atach.user_id == current_user.id || is_admin?) ? true : false
  end
end
