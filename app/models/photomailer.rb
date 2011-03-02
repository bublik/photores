class Photomailer < ActionMailer::Base

  def new_photo(photo, user)
    setup_email(photo, user)
  end
  
  def complaint_photo(photo, user)
    setup_email(photo, user)
    attachment :content_type => "image/jpeg",
      :body => File.read(photo.full_filename(:crop)) unless photo.current_state.eql?(:delete)
  end

  def updated_photo(photo, user)
    setup_email(photo, user)
    attachment :content_type => "image/jpeg",
      :body => File.read(photo.full_filename(:crop)) unless photo.current_state.eql?(:delete)
  end
  
  protected
  def setup_email(photo, user)
    subject       "[#{APP_CONFIG['site_name']}] #{photo.current_state}"
    recipients    user.email
    from          APP_CONFIG['admin_email']
    sent_on       Time.current
    body[:user]  = user
    body[:photo] = photo
    body[:photo_link] = url_for(:only_path => false,
      :controller => 'photos',
      :action => 'show',
      :id => photo)
  end
end
