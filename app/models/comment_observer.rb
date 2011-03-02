class CommentObserver < ActiveRecord::Observer
  def after_create(record)
    #Отправляем автору письмо о новом коментарие к его фотографии
    if record.user.subscribed && record.commentable_type.eql?('Photo')
      Mailer.deliver_new_photo_comment(record.photo.user, record.photo)
    end
  end
end
