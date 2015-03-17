class Lead < ActiveRecord::Base
	default_scope { where(school_id: School.current_id) if School.current_id }
	
  attr_accessible :email, :course

  validates :email, presence: true, 
                    uniqueness: { scope: [:course_id] },
                    format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  belongs_to :course
	before_create :save_current_school_id

  def save_current_school_id
    self.school_id = School.current_id
  end
end
