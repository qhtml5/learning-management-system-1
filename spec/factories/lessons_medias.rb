# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lesson_media do
  	add_attribute :sequence, 1
    lesson
    media
  end
end
