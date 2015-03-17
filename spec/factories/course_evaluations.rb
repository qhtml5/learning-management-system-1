# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course_evaluation do
    comment "MyText"
    score "5"
    user
    course
  end
end
