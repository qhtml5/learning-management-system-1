class Lesson < ActiveRecord::Base
	include RankedModel
	ranks :sequence, with_same: :course_id

  # extend FriendlyId
  # friendly_id :title, use: :scoped, scope: :course
	
	attr_accessible :course, :title, :sequence

	scope :available, joins(:lessons_medias).where("lessons_medias.media_id IS NOT NULL").uniq

	has_many :lessons_medias, dependent: :destroy
	has_many :medias, :through => :lessons_medias
	has_many :teachers, through: :course, source: :teachers
	has_many :notifications, as: :notifiable, dependent: :delete_all

	belongs_to :course

	validates :title, length: { minimum: 5, maximum: 100 }
	validates :course, presence: true

	accepts_nested_attributes_for :lessons_medias
	
end
