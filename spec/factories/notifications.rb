# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    receiver factory: :school_admin
    sender factory: :student
    code Notification::USER_NEW_REGISTRATION
    notifiable factory: :student
  end
end
