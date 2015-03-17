class CourseCategory < ActiveRecord::Base
	include RankedModel
	ranks :sequence

	default_scope { where(school_id: School.current_id) if School.current_id }

  attr_accessible :name

  has_many :courses
  
  before_create :save_current_school_id

  validates :name, presence: true, uniqueness: { scope: [:school_id] }

  def save_current_school_id
		self.school_id = School.current_id
	end
end
