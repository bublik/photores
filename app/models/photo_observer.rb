class PhotoObserver < ActiveRecord::Observer

  #Отсылать друзьям информацию о новой работе
  def after_create(photo)
    return unless photo.is_parent?
    if !photo.photo_albums.collect{|a| a if a.frendly }.empty?
      photo.user.friends.each{|f| Photomailer.deliver_new_photo(photo, f) if f.subscribed}
    end
  end

  #Отсылать автору для коментариев, изменения рейтинга и жалоб
  def after_update(photo)
    return unless photo.is_parent?
    photo.user.subscribed

    if photo.current_state.eql?(Photo.states[:complaint])
      Photomailer.deliver_complaint_photo(photo, photo.user) if photo.user.subscribed
    elsif photo.current_state
      photo.user.friends.each do |f|
        #Send email to frend about photo
        Photomailer.deliver_updated_photo(photo, f) if f.subscribed
      end
    end
  end

  #Отсылать автору фото
  def after_destroy(photo)
    return unless photo.is_parent?
    Photomailer.deliver_new_photo(photo, photo.user) if photo.user.subscribed
  end
  
end
