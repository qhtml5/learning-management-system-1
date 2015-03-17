class MessageAnswer < ActiveRecord::Base
	attr_accessible :answer, :message
	
	has_many :notifications, as: :notifiable, dependent: :delete_all
	
  belongs_to :answer, class_name: "Message"
  belongs_to :message

end
