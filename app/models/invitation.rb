class Invitation < ActiveRecord::Base
  default_scope { where(school_id: School.current_id) if School.current_id }

  attr_accessible :email, :role, :school, :status, :course

  belongs_to :school
  belongs_to :course

  validates :email, presence: true, 
                    uniqueness: { scope: [:school_id, :course_id] },
                    format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  # validates :role, presence: true
  # validates :school, presence: true
  validates :course, presence: true

  after_create :create_notification

  before_create :save_current_school_id

  def save_current_school_id
    self.school_id = School.current_id unless self.school
  end

  def self.create_list args = {}
  	result = {}
    result[:success] = []
    result[:failure] = []

    args[:emails].each do |email|
      invitation = Invitation.find_or_create_by_email_and_course_id(email, args[:course].id) do |invitation|
        invitation.course = args[:course]
        invitation.school_id = Course.find(args[:course]).school.id
      end
      if invitation.errors.empty?
    		result[:success] << invitation
      else
        result[:failure] << invitation
      end
    end

    result
  end

  def create_notification
    user = User.find_by_email_and_school_id(self.email, School.current_id)

    if user
      Notification.create(
        receiver: user,
        code: Notification::USER_NEW_COURSE_INVITATION,
        notifiable: self
      )
    else
      Notification.create(
        email: self.email,
        code: Notification::USER_NEW_COURSE_INVITATION,
        notifiable: self
      )
    end  
  end

end
