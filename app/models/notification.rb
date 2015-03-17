class Notification < ActiveRecord::Base
	USER_NEW_REGISTRATION = 100
  USER_NEW_INVITATION = 101
  USER_NEW_COURSE_INVITATION = 102
  USER_SIGN_IN = 103
  USER_VIEW_COURSE_CONTENT = 104
  USER_STARTED_MEDIA = 105
  USER_ENDED_MEDIA = 106
  USER_NEW_CONTACT = 107
  USER_SCHOOL_NEW_CONTACT = 108

	COURSE_NEW_QUESTION = 200
	COURSE_NEW_ANSWER = 201
	COURSE_ADD_TO_CART = 202
  COURSE_NEW_EVALUATION = 203
  COURSE_UPDATE = 204
  COURSE_CURRICULUM_UPDATE = 205
  COURSE_NEW_CERTIFICATE_REQUEST = 206
  COURSE_VIEW_PAGE = 207

	PURCHASE_PENDING = 300
	PURCHASE_CONFIRMED = 301
  PURCHASE_USER_PENDING = 302
  PURCHASE_USER_CONFIRMED = 303
  PURCHASE_USER_LIBERATED = 304
  PURCHASE_LIBERATED = 305

  SCHOOL_PLAN_CHOOSE = 401
  SCHOOL_PLAN_CHANGE = 402

  SENT_TO_SCHOOL_ADMIN = [ USER_NEW_REGISTRATION, USER_NEW_CONTACT, COURSE_NEW_QUESTION, 
                            COURSE_ADD_TO_CART, COURSE_NEW_EVALUATION, COURSE_NEW_CERTIFICATE_REQUEST,
                            PURCHASE_PENDING, PURCHASE_CONFIRMED, PURCHASE_LIBERATED
                          ]

  SENT_BY_STUDENT = [ COURSE_NEW_QUESTION, COURSE_NEW_ANSWER, COURSE_NEW_EVALUATION,
                      PURCHASE_PENDING, PURCHASE_CONFIRMED, PURCHASE_LIBERATED, COURSE_ADD_TO_CART,
                      USER_NEW_REGISTRATION, COURSE_NEW_CERTIFICATE_REQUEST,
                      USER_SIGN_IN, USER_STARTED_MEDIA, USER_ENDED_MEDIA,
                      USER_VIEW_COURSE_CONTENT, USER_NEW_CONTACT ]

  MEDIA_NOTIFICATIONS = [ USER_ENDED_MEDIA, USER_STARTED_MEDIA ]

  TIME_SENSITIVE_NOTIFICATIONS = [ USER_VIEW_COURSE_CONTENT, USER_SIGN_IN ]

  attr_accessible :receiver, :sender, :read, :code, :notifiable, :message, 
                  :email, :personal

  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  validates :receiver, presence: true, if: :not_personal_and_email_not_present?
  validates :email, presence: true, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, if: :not_personal_and_receiver_not_present?
  validates :code, presence: true
  validates :notifiable, presence: true

  scope :unread, where(read: false)
  scope :sent_by_students, where(code: SENT_BY_STUDENT)
  scope :personal, where(personal: true)
  scope :not_personal, where(personal: false)
  scope :started_media, where(code: USER_STARTED_MEDIA)
  scope :ended_media, where(code: USER_ENDED_MEDIA)
  scope :course_add_to_cart, where(code: COURSE_ADD_TO_CART)
  scope :course_view_page, where(code: COURSE_VIEW_PAGE)
  scope :between, lambda { |start_date, end_date| 
    where("notifications.created_at between ? and ?", start_date.to_datetime.change(:hour => 00, :min => 00, :sec => 00), end_date.to_datetime.change(:hour => 23, :min => 59, :sec => 59)) 
  }

  after_create :send_mail, unless: :personal?
  before_create :check_if_its_not_repeated, if: :personal?

  def check_if_its_not_repeated
    if MEDIA_NOTIFICATIONS.include? self.code
      false if Notification.find_by_sender_id_and_code_and_notifiable_type_and_notifiable_id(self.sender_id, self.code, self.notifiable_type, self.notifiable_id).present?
    elsif TIME_SENSITIVE_NOTIFICATIONS.include? self.code
      false if Notification.where("created_at between ? and ?", Time.now - 2.hours, Time.now).find_by_sender_id_and_code_and_notifiable_type_and_notifiable_id(self.sender_id, self.code, self.notifiable_type, self.notifiable_id).present?
    end
  end

  def self.find_all_by_media media_ids
    self.where(notifiable_type: "Media", notifiable_id: media_ids)
  end

  def self.create_list args = {}
    result = []

    args[:receivers].uniq.each do |receiver|
      result << Notification.create(
        sender: args[:sender],
        receiver: receiver,
        code: args[:code],
        message: args[:message],
        notifiable: args[:notifiable]
      ) unless args[:sender] == receiver
    end if args[:receivers]

    args[:emails].uniq.each do |email|
      result << Notification.create(
        sender: args[:sender],
        email: email,
        code: args[:code],
        message: args[:message],
        notifiable: args[:notifiable]
      )
    end if args[:email]
    result
  end

  def not_personal_and_receiver_not_present?
    !self.personal && !self.receiver.present?
  end

  def not_personal_and_email_not_present?
    !self.personal && !self.email.present?
  end

  def invitation_notification?
    self.notifiable.is_a? Invitation
  end

  def send_mail
    mail = { USER_NEW_REGISTRATION => :user_new_registration,
      USER_NEW_INVITATION => :user_new_invitation,
      USER_NEW_COURSE_INVITATION => :user_new_course_invitation,
      COURSE_NEW_QUESTION => :course_new_question,
      COURSE_NEW_ANSWER => :course_new_answer,
      COURSE_ADD_TO_CART => :course_add_to_cart,
      COURSE_NEW_EVALUATION => :course_new_evaluation,
      COURSE_UPDATE => :course_update,
      COURSE_CURRICULUM_UPDATE => :course_curriculum_update,
      COURSE_NEW_CERTIFICATE_REQUEST => :course_new_certificate_request,
      PURCHASE_PENDING => :purchase_pending,
      PURCHASE_CONFIRMED => :purchase_confirmed,
      PURCHASE_LIBERATED => :purchase_liberated,
      PURCHASE_USER_PENDING => :purchase_user_pending,
      PURCHASE_USER_CONFIRMED => :purchase_user_confirmed,
      PURCHASE_USER_LIBERATED => :purchase_user_liberated,
      SCHOOL_PLAN_CHOOSE => :school_plan_choose,
      SCHOOL_PLAN_CHANGE => :school_plan_change,
      USER_NEW_CONTACT => :user_new_contact,
      USER_SCHOOL_NEW_CONTACT => :user_school_new_contact
    }[self.code]
    school = School.find_by_id(School.current_id)
    if school && school.notification_configuration && SENT_TO_SCHOOL_ADMIN.include?(self.code)
      NotificationMailer.send(mail, self).deliver if school.notification_configuration.send(mail)
    else 
      NotificationMailer.send(mail, self).deliver
    end
  end

  def personal?
    self.personal
  end

end
