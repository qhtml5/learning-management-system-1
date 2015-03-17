FactoryGirl.define do
  factory :user do
		first_name "F_FIRST_NAME"
		last_name "F_LAST_NAME"
		email { "F_EMAIL#{rand(100)}#{rand(100)}#{rand(100)}@EMAIL.COM" }
		password "123456"
		cpf '138.658.097-07'
		phone_number '2298992600'
		address

		factory :student do
			callback(:after_create) do |user|
	  		user.role = "student"
	  		user.save!
	  	end
		end
		
	  factory :admin do
	  	callback(:after_create) do |user|
	  		user.role = "admin"
	  		user.save!
	  	end
	  end

	  factory :teacher do
	  	callback(:after_create) do |user|
	  		user.role = "teacher"
	  		user.save!
	  	end
	  end

	  factory :school_admin do
	  	callback(:after_create) do |user|
	  		user.school = FactoryGirl.create(:school, users: [user]) unless user.school
	  		user.role = "school_admin"
	  		user.save!
	  	end
	  end
  end
end
