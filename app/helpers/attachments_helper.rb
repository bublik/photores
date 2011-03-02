module AttachmentsHelper

=begin
Выдает  в строку список атачей для сообщения
=end
  def attachemts_list(mesg)
    mesg.attachments.collect{ |file| attachment_link(file) }.join(' ')
  end

  def attachment_link(file)
    file.is_image? ?
      link_to(file.is_exist_thumb? ? image_tag(file.public_filename(:thumb)) : image_tag(file.public_filename),  file.public_filename, :class => 'slide') :
      link_to(file.filename, attachment_url(file))
  end

end
