ActionMailer::Base.smtp_settings = {
  :user_name      => 'edools',
  :password       => 'CTY$%&opl',
  :domain         => 'edools.com',
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :enable_starttls_auto => true
}
# ActionMailer::Base.smtp_settings = {
#   :address        => 'smtp.sendgrid.net',
#   :port           => '587',
#   :authentication => :plain,
#   :user_name      => ENV['SENDGRID_USERNAME'],
#   :password       => ENV['SENDGRID_PASSWORD'],
#   :domain         => 'heroku.com'
# }
ActionMailer::Base.delivery_method ||= :smtp