class CourseUser < ActiveRecord::Base
  attr_accessible :course, :user, :created_at

  belongs_to :course
  belongs_to :user

  scope :within_validity, joins(:course).where(
    "DATE_ADD(courses_users.created_at, INTERVAL courses.available_time DAY) > ? OR courses.available_time = 0", Time.now
  )
  scope :out_of_date, joins(:course).where(
    "courses.available_time <> 0 AND DATE_ADD(courses_users.created_at, INTERVAL courses.available_time DAY) < ?", Time.now
  )

  scope :published, joins(:course).where(courses: { :status => "published" })                            

  def out_of_date?
  	!self.within_validity?
  end

  def within_validity?
    course.limited? ? self.expires_at > Time.now : true
  end

  def expires_at
    self.created_at + self.course.available_time.days if self.course.limited?
  end

  def status
    self.within_validity? ? :within_validity : :out_of_date
  end

  def limited?
    self.course.limited?
  end  

end
