# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    text "F_TEXT_MESSAGE"
    user
    course
  end
end
