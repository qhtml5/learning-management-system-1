class LessonMedia < ActiveRecord::Base
	include RankedModel
	ranks :sequence, with_same: :lesson_id
	
	attr_accessible :sequence, :media, :lesson

	belongs_to :lesson
	belongs_to :media

	has_many :notifications, as: :notifiable, dependent: :delete_all

	validates :sequence, :presence => true
	validates :lesson, presence: true
end
