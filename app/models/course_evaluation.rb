class CourseEvaluation < ActiveRecord::Base  
  belongs_to :user
  belongs_to :course

  has_many :notifications, as: :notifiable, dependent: :delete_all
  
  attr_accessible :comment, :score, :user, :course
  
  validates :user, presence: true
  validates :course, presence: true
  validates :score, presence: true
  
end
