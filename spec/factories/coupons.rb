# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coupon do
    discount 10
    name "F_NAME"
    expiration_date { Date.today + 10.days }
    quantity 50
    course
  end
end
