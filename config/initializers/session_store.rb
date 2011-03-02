ActionController::Base.session = {
  :domain => ".#{APP_CONFIG['domain']}",
  :expire_after => 14.days,
}
ActionController::Base.session_store = :active_record_store
