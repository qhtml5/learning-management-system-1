# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
    email { "F_EMAIL#{rand(100)}#{rand(100)}#{rand(100)}@EMAIL.COM" }
    course
  end
end
