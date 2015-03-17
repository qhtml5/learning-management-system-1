# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school do
  	name "F_SCHOOL_NAME"
		sequence(:subdomain) { |n| "school#{n}#{rand(100)}" }
		moip_login "school_login"
		plan "trial"
		users { [FactoryGirl.create(:school_admin)] }
  end
end
