Rails.application.config.middleware.use OmniAuth::Builder do
  # The following is for facebook
  provider :facebook, AppSettings.facebook_key, AppSettings.facebook_secret, { :scope => "email", :client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}} }

  # {:scope => 'email, read_stream, read_friendlists, friends_likes, friends_status, offline_access'}
 
  # If you want to also configure for additional login services, they would be configured here.
end