source 'https://rubygems.org'
ruby '1.9.3'

gem 'rails', '~> 3.2.9'
gem 'thin'
# gem 'pg'
gem 'mysql2'

gem 'devise', '~> 2.0'
gem 'omniauth'
gem 'omniauth-facebook', '1.4.0'
gem 'oauth2'
gem 'jquery-rails'
gem 'apotomo'
gem 'mymoip'
gem 'tinymce-rails'
gem 'brcpfcnpj'
gem 'hashie'
gem 'cancan'
gem 'twitter-bootstrap-rails', '~> 2.2.4'
gem 'friendly_id'
gem 'ranked-model'
gem 'km'
gem 'paperclip', "~> 3.0"
gem 'aws-sdk'
gem 'wistia-api'
gem 'multipart-post'
gem "flip" # To flip features
gem 'best_in_place'
gem 'simple_form'
gem 'rails-subdomain'
gem 'exception_notification', '~> 3.0.1'
gem 'net-dns'
gem 'wicked_pdf', '~> 0.9.6'
gem 'bootstrap-wysihtml5-rails'
gem 'delayed_job_active_record'
gem 'kaminari'
gem 'rack-mini-profiler'
gem 'whenever', require: false
gem 'yaml_db'

group :development do
  gem 'sqlite3'
  gem 'i18n_generators'
  gem 'better_errors' # replaces the standard Rails error page with a much better and more useful error page
  gem 'binding_of_caller' # add advanced feature to better_errors
  gem "parallel_tests"
end

group :development, :test, :staging do  
  gem 'capybara', '~> 2.0.2'
  gem 'rspec'
  gem 'rspec-rails', '~> 2.14.0.rc1'
  gem 'factory_girl', '~> 4.0'
  gem 'factory_girl_rails', '~> 4.0'
  gem "valid_attribute", "~> 1.3.1"
  gem 'database_cleaner', '~> 0.8'  
  gem 'rspec-apotomo'
  gem 'letter_opener'
  gem 'pry', '~> 0.9.11'
  gem 'pry-rails', '~> 0.2.2'
  gem 'pry-remote'
  gem 'pry-nav'
end

group :test do
  gem 'poltergeist', '~> 1.1.0'
  gem "capybara-webkit", "~> 0.14.2"
  gem 'launchy', '~> 2.2.0' # to save and open page on acceptance specs
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'toothbrush', '~> 0.1.3' # ensure_table matcher
  gem 'shoulda-matchers'
end

# TODO: Verificar se eh necessario manter as gem sass-rails
group :assets do
  gem 'therubyracer', :platforms => :ruby
  gem 'sass-rails',   '~> 3.2.3'
  gem 'less-rails', '~> 2.2.6'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'minitest'
end