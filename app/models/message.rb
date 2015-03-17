class Message < ActiveRecord::Base
	COURSE_QUESTION = 1
	COURSE_ANSWER = 2
  CONTACT = 3
  ANNOTATION = 4

  attr_accessible :course, :text, :user, :messages_answers, :kind, :receiver

  belongs_to :user
  belongs_to :course
  belongs_to :receiver, class_name: "User"

  has_many :messages_answers
  has_many :answers, through: :messages_answers
  has_many :notifications, as: :notifiable, dependent: :delete_all

  validates :text, length: { minimum: 10, maximum: 5000 }
  validates :user, presence: true

  scope :questions, where(kind: COURSE_QUESTION)
  scope :answers, where(kind: COURSE_ANSWER)
end
