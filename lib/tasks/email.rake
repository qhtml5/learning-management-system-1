def config_mail_production
  ActionMailer::Base.default_url_options = { :host => "academia.bizstart.com.br" }
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => "academia@bizstart.com.br",
    :password             => 'Ac23Bi98',
  }
end

namespace :email do
	task :new_purchase, [:email, :course_id, :env] => [:environment] do |t, args|
		config_mail_production if args[:env] == "production"
		@user = User.find_by_email args[:email]
		@course = Course.find args[:course_id]
		Mailer.new_purchase(@user, @course).deliver
	end

	task :new_workshop_purchase, [:email, :course_id, :env] => [:environment] do |t, args|
		config_mail_production if args[:env] == "production"
		@user = User.find_by_email args[:email]
		@course = Course.find args[:course_id]
		Mailer.new_workshop_purchase(@user, @course).deliver
	end

	task :purchase_confirmation, [:email, :course_id, :env] => [:environment] do |t, args|
		config_mail_production if args[:env] == "production"
		@user = User.find_by_email args[:email]
		@course = Course.find args[:course_id]
		Mailer.purchase_confirmation(@user, @course).deliver
	end

	task :workshop_confirmation, [:email, :course_id, :env] => [:environment] do |t, args|
		config_mail_production if args[:env] == "production"
		@user = User.find_by_email args[:email]
		@course = Course.find args[:course_id]
		Mailer.workshop_confirmation(@user, @course).deliver
	end
end