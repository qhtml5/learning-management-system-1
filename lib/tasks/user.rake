namespace :user do
	task :destroy, [:email] => [:environment] do |t, args|
		@user = User.find_by_email args[:email]
		@user.destroy
	end
end