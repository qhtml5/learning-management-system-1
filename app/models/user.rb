#coding: utf-8

class User < ActiveRecord::Base    

  SCHOOL_ROLES = { "Administrador" => "school_admin", "Professor" => "teacher" }

  ADMIN = "admin"
  SCHOOL_ADMIN = "school_admin"
  STUDENT = "student"
  TEACHER = "teacher"

  ROLES = { "Administrador Geral" => "admin", "Professor" => "teacher", 
            "Administrador" => "school_admin", "Aluno" => "student" }

  SCHOOL_ADMIN_ROLE = "Administrador"

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, request_keys: [:subdomain]

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, 
                  :remember_me, :address_attributes, :skype, :cpf, :phone_number, 
                  :image_url, :biography, :address, :image, :company, :function, :current_password
  cattr_accessor :current_status, :current_id
  attr_accessor :current_password

  has_attached_file :image, :styles => { :medium => "100x100>", :small => "40x40>", 
                                         :thumb => "30x30>", :mini_thumb => "15x15>" }, 
                            :default_url => '/images/:attachment/missing_:style.jpg'

  belongs_to :school

  has_one :address

  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :authentications, dependent: :delete_all
  has_many :purchases
  has_many :lessons, :through => :courses_invited
  has_many :lessons_medias, :through => :lessons
  has_many :medias, :through => :lessons_medias
  has_many :course_evaluations
  has_many :notifications_received, class_name: "Notification", foreign_key: 'receiver_id'
  has_many :notifications_sent, class_name: "Notification", foreign_key: 'sender_id'
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :messages_received, class_name: "Message", foreign_key: 'receiver_id', conditions: { kind: Message::CONTACT }
  has_many :annotations, class_name: "Message", foreign_key: 'receiver_id', conditions: { kind: Message::ANNOTATION }

  has_many :cart_items, through: :purchases
  has_many :cart_items_within_validity, through: :purchases, source: :cart_items, include: :course, conditions: ["DATE_ADD(cart_items.confirmed_at, INTERVAL courses.available_time DAY) > ? OR courses.available_time = 0 OR cart_items.confirmed_at IS NULL", Time.now], uniq: true
  has_many :cart_items_out_of_date, through: :purchases, source: :cart_items, include: :course, conditions: ["courses.available_time <> 0 AND cart_items.confirmed_at IS NOT NULL AND DATE_ADD(cart_items.confirmed_at, INTERVAL courses.available_time DAY) < ?", Time.now], uniq: true

  has_many :courses_as_student, through: :cart_items, source: :course, uniq: true
  has_many :courses_as_student_within_validity, through: :cart_items_within_validity, source: :course, uniq: true
  has_many :courses_as_student_out_of_date, through: :cart_items_out_of_date, source: :course, uniq: true

  has_many :courses_users
  has_many :courses_users_within_validity, class_name: "CourseUser", include: :course, conditions: ["DATE_ADD(courses_users.created_at, INTERVAL courses.available_time DAY) > ? OR courses.available_time = 0", Time.now], uniq: true
  has_many :courses_users_out_of_date, class_name: "CourseUser", include: :course, conditions: ["courses.available_time <> 0 AND DATE_ADD(courses_users.created_at, INTERVAL courses.available_time DAY) < ?", Time.now], uniq: true

  has_many :courses_invited, through: :courses_users, source: :course, uniq: true
  has_many :courses_invited_within_validity, through: :courses_users_within_validity, source: :course, uniq: true
  has_many :courses_invited_out_of_date, through: :courses_users_out_of_date, source: :course, uniq: true
  
  validates :first_name, length: { within: 2..100 }
  validates :email, format: Devise.email_regexp
  validates :email, uniqueness: { scope: [:school_id] }
  validates :password, presence: true, on: :create
  validates :password, length: { within: Devise.password_length }, allow_blank: :true
  validates :last_name, length: { within: 2..100 }, if: :purchasing?
  validates :phone_number, length: { within: 10..11 }, if: :purchasing?
  validates :address, presence: true, if: :purchasing?
  validates :cpf, presence: true, if: :purchasing?
  validates :company, presence: true, if: :purchasing_free?
  validates :function, presence: true, if: :purchasing_free?

  scope :admins, where(role: "admin")
  scope :not_students, where(role: ["school_admin","teacher","admin"])
  scope :not_admins, where(role: ["school_admin","teacher","student"])
  
  usar_como_cpf :cpf

  before_validation :remove_masks
  before_validation :save_current_school_id, on: :create
  before_create :set_role
  
  accepts_nested_attributes_for :address

  class << self
    def find_all_by_full_name full_name
      if full_name.split(" ").length == 1
        where("first_name LIKE ? OR last_name LIKE ?", "%#{full_name}%", "%#{full_name}%")
      else
        find(:all, :conditions => ["concat(first_name,' ',last_name) like?", "%#{full_name}%"])
      end
    end

    def find_for_authentication(warden_conditions)
      if warden_conditions[:subdomain] == "www"
        User.not_students.find_by_email(warden_conditions[:email])
      elsif school = School.find_by_subdomain(warden_conditions[:subdomain])
        school.users.find_by_email(warden_conditions[:email])
      end
    end

    def send_reset_password_instructions(attributes={})      
      recoverable = if attributes[:subdomain] == "www"
        User.not_students.find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
      elsif school = School.find_by_subdomain(attributes[:subdomain])
        school.users.find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
      end

      recoverable.send_reset_password_instructions if recoverable.persisted?
      recoverable
    end

    def to_csv(options = {})
      CSV.generate(options) do |csv|
        csv << ["Id","Email","Data de entrada","Nome","Sobrenome","Telefone",
                "Endereço","CPF","Empresa","Cargo","Skype"]
        all.each do |user|
          csv << [
            user.id,
            user.email,
            user.created_at.strftime('%d/%B/%Y %H:%M'),
            user.first_name,
            user.last_name,
            user.phone_number,
            user.full_address,
            user.cpf,
            user.company,
            user.function,
            user.skype
          ]
        end
      end
    end    
  end

  def password_has_changed?
    self.password_changed?
  end

  def set_role
    self.role = School.current_id ? User::STUDENT : User::SCHOOL_ADMIN
  end

  def save_current_school_id
    self.school_id = School.current_id
  end

  def purchasing?
    User.current_status == :purchasing
  end

  def editing?
    User.current_status == :editing
  end

  def purchasing_free?
    User.current_status == :purchasing_free
  end

  def remove_masks
    self.phone_number.gsub!(/\D+/, "") if self.phone_number
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def apply_omniauth(auth)
    self.image_url = auth['info']['image']
	  self.email = auth['extra']['raw_info']['email']
    self.first_name = auth['extra']['raw_info']['first_name']
    self.last_name = auth['extra']['raw_info']['last_name']
	  self.authentications.build(:provider => auth['provider'], :uid => auth['uid'], :token => auth['credentials']['token'])
    self.password = Devise.friendly_token[0,20]
	end

  def admin?
    self.role == ADMIN
  end

  def teacher?
    self.role == TEACHER
  end

  def student?
    self.role == STUDENT
  end

  def school_admin?
    self.role == SCHOOL_ADMIN
  end

  def name_to_show
    self.first_name.capitalize
  end

  def can_answer_in_course? course
    self.admin? || ((self.school_admin? || self.teacher?) && self.courses.include?(course))
  end

  def password_required?
    !self.persisted? || !self.password.nil? || !self.password_confirmation.nil?
  end

  def email_required?
    true
  end

  def courses
    if self.school_admin?
      self.school.courses
    elsif self.teacher?
      self.courses_as_teacher
    elsif self.student?
      self.courses_as_student + self.courses_invited
    elsif self.admin?
      Course.unscoped
    end
  end

  def courses_confirmed
    if self.student?
      self.courses_as_student.payment_confirmed + self.courses_invited
    else
      self.courses
    end
  end

  def courses_as_teacher
    self.courses_invited
  end

  def register_on_rdstation identificator
    school = School.find_by_id(School.current_id)
    if Rails.env.production? && school && school.token_rdstation
      params = { "token_rdstation" => school.token_rdstation, 
                 "identificador" => identificator, 
                 "email" => self.email, 
                 "nome" => self.full_name,
                 "cargo" => self.function,
                 "empresa" => self.company
                }
      uri = URI.parse("https://www.rdstation.com.br/api/1.2/conversions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(params)
      response = http.start {|http| http.request(request) }
    end
  end

  def started_media? media
    self.notifications_sent.started_media.find_all_by_media(media.id).present?
  end

  def ended_media? media
    self.notifications_sent.ended_media.find_all_by_media(media.id).present?
  end

  def ended_medias course
    media_ids = course.medias.available.map(&:id)
    self.notifications_sent.ended_media.find_all_by_media(media_ids).length
  end

  def started_medias course
    media_ids = course.medias.available.map(&:id)
    self.notifications_sent.started_media.find_all_by_media(media_ids).length
  end

  def completed_progress course
    if course.medias.available.length == 0
      "100%"
    else
      "#{((self.ended_medias(course).to_f / course.medias.available.length.to_f) * 100).to_i}%"
    end
  end

  def started_progress course
    "#{(self.started_medias(course).to_f / course.medias.available.length.to_f) * 100}%"
  end

  def full_address
    if self.address.present?
      "#{self.address.street} #{self.address.number} #{self.address.complement}" +
      "#{self.address.city}/#{self.address.state} - CEP #{self.address.zip_code}"
    end
  end

  def city_state
    if self.address.present?
      "#{self.address.city}/#{self.address.state}"
    end
  end

  def courses_titles
    self.courses.uniq.map(&:title).join(", ")
  end

  def active?
    self.courses_invited_within_validity.present? || self.courses_as_student_within_validity.present?
  end

  def destroy_lead 
    lead = Lead.find_by_email(self.email)
    lead.destroy if lead
  end

  def full_name_capitalized
    self.full_name.split.map(&:capitalize).join(' ')
  end
end
