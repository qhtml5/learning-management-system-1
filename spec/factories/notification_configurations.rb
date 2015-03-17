# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_configuration do
    user_new_registration false
    user_new_contact false
    course_new_question false
    course_add_to_cart false
    course_new_evaluation false
    course_new_certificate_request false
    purchase_pending false
    purchase_confirmed false
  end
end
