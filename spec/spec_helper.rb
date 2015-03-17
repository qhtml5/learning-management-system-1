require 'rubygems'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  SimpleCov.coverage_dir 'coverage/rspec'
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'valid_attribute'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'database_cleaner'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

module Helpers
  def fill_in_inputmask(location, options={})
    len = options[:with].to_s.length - 1
    len.times do
      fill_in location, :with => '1'
    end
    fill_in location, options
  end
end

RSpec.configure do |config|
  config.include Helpers, :type => :feature
  config.include FactoryGirl::Syntax::Methods
  config.include Warden::Test::Helpers
  
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  Warden.test_mode!
  OmniAuth.config.test_mode = true  
  Capybara.javascript_driver = :webkit
  Capybara.always_include_port = true
  Capybara.automatic_reload = false    

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    ActionMailer::Base.deliveries.clear
    stubs
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    switch_to_subdomain
    School.current_id = nil
    User.current_status = nil
  end    

  config.after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end    
end

class ActionController::TestCase
  include Devise::TestHelpers
end

def switch_to_subdomain(subdomain = "")
  unless subdomain.blank?
    Capybara.app_host = "http://#{subdomain}.lvh.me"
  else
    Capybara.app_host = "http://www.lvh.me"
  end
end

def stubs
  KM.stub :identity => true, :alias => true, :record => true
  Wistia::Media.stub find: Wistia::Media.new(embedCode: "embedCode"), create: Wistia::Media.new(embedCode: "embedCode")
  Wistia::Media.any_instance.stub_chain(:assets, :first, :url).and_return("http://embed.wistia.com/deliveries/0cd275f0f505fc8b98895239201e445c49706757.bin")
  Wistia::Project.stub find: Wistia::Project.new, create: Wistia::Project.new
  User.any_instance.stub register_on_rdstation: true
  [ Users::SessionsController, Users::RegistrationsController,
    Users::PasswordsController, CheckoutsController, CoursesController].each do |controller|
      controller.any_instance.stub use_https?: false
  end
end