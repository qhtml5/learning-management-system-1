namespace :admin do
	task :add, [:email] => [:environment] do |t, args|
		email = args[:email]
		@user = User.find_by_email email
		@user.roles = ["admin"]
		@user.save!
	end

	task :remove, [:email] => [:environment] do |t, args|
		email = args[:email]
		@user = User.find_by_email email
		@user.save!
	end
end