FactoryGirl.define do
  factory :authentication do
		provider :facebook
		uid "12345"
		token "token_teste"
		user
  end
end
