class NotificationConfiguration < ActiveRecord::Base
  attr_accessible :course_add_to_cart, :course_new_certificate_request, :course_new_evaluation, 
  								:course_new_question, :purchase_confirmed, :purchase_pending, :user_new_contact, 
  								:user_new_registration, :purchase_liberated

  belongs_to :school
end
