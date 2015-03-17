#coding: utf-8

class Course < ActiveRecord::Base
  default_scope { where(school_id: School.current_id) if School.current_id }
  
  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :school

  MINIMUM_PRICE = 3000

  PUBLISHED = "published"
  DRAFT = "draft"

  PRIVATE = "private" 
  PUBLIC = "public"
  RESTRICT = "restrict"
  
  STATUS = { "Rascunho" => DRAFT, "Publicado" => PUBLISHED }
  PRIVACY = { "Privado" => PRIVATE, "Público" => PUBLIC, "Restrito" => RESTRICT }
  PRIVACIES = [ PRIVATE, PUBLIC, RESTRICT ]

  ILIMITED = "ilimited"
  LIMITED = "limited"

  attr_accessible :title, :description, :price, :pitch, :logo_url, 
                  :video_url, :video_title, :video_subtitle, :last_call_to_action, 
                  :content, :staging_mailchimp_grouping, :production_mailchimp_grouping, 
                  :testimonials, :small_logo_url, :courses_medias_attributes, :status, 
                  :teachers, :students, :logo, :wistia_public_project_id, :privacy, 
                  :who_should_attend, :content_and_goals, :downloads, :wistia_promo_video_id, 
                  :lessons, :medias, :school, :allowed_emails, :available_time, :advantages,
                  :certificate_available, :instructor_bio, :course_category_id, :accept_download

  has_attached_file :logo, :styles => { :large => "480x270>", 
                                        :medium => "260x146>", 
                                        :small => "110x62>" },
                           :default_url => '/images/:attachment/missing_:style.png'

  has_many :cart_items, dependent: :destroy
  
  has_many :purchases, :through => :cart_items
  has_many :students_purchased, through: :purchases, source: :user, uniq: true
  has_many :lessons, dependent: :delete_all
  has_many :lessons_medias, :through => :lessons
  has_many :medias, :through => :lessons_medias

  has_many :notifications, as: :notifiable, dependent: :delete_all

  has_many :courses_users
  has_many :teachers, through: :courses_users, source: :user, conditions: { role: "teacher" }
  has_many :students_invited, through: :courses_users, source: :user, conditions: { role: "student" }, uniq: true

  has_many :messages
  has_many :questions, class_name: "Message", conditions: { kind: Message::COURSE_QUESTION }
  has_many :coupons, dependent: :delete_all
  has_many :course_evaluations
  
  belongs_to :course_category

  has_many :leads

  has_many :invitations

  belongs_to :school

  scope :payment_confirmed, joins(:purchases).
                            where(:purchases => { :payment_status => ["Concluido","Autorizado"] })
  scope :payment_pending, joins(:purchases).
                          where("purchases.payment_status not in (?)", ["Concluido","Autorizado"])
  scope :published, where(:status => PUBLISHED)
  scope :no_category, where("course_category_id IS NULL")
  scope :not_private, where(:privacy => [PUBLIC, RESTRICT])

  scope :ilimited, where(available_time: 0)
  scope :limited, where("available_time > 0")

  before_validation :save_current_school_id, on: :create
  
  validates :school, presence: true
  validates :title, length: { minimum: 5, maximum: 48 }
  validates :pitch, length: { minimum: 5, maximum: 120 }, if: :published?
  validates :who_should_attend, length: { minimum: 10, maximum: 5000 }, if: :published?
  validates :content_and_goals, length: { minimum: 10, maximum: 5000 }, if: :published?
  validates :description, length: { minimum: 10, maximum: 50000 }, if: :published?
  validates :logo, presence: true, if: :published?

  validate :media_presence, if: :published?
  validate :price_greater_than_minimum, if: :published?
  validate :school_moip_login_presence, if: :published?

  validates_attachment_content_type :logo, :content_type => /^image\/(jpg|jpeg|pjpeg|png|x-png|gif)$/, 
                                           :message => 'inválido (permitido apenas jpeg/png/gif)'

  def save_current_school_id
    self.school_id = School.current_id unless self.school
  end

  def school_moip_login_presence
    #TODO: Remover condicional Elekeiroz 
    unless (self.school && self.school.moip_login.present?) || self.school.subdomain == "elekeiroz"
      self.errors.add :school, :must_have_moip_login 
    end
  end

  def media_presence
    unless self.medias.available.any?
      self.errors.add :lessons, :must_have_at_least_one_media_with_content
    end
  end

  def price_greater_than_minimum
    unless self.price > 2999 || self.school.can_create_free_course
      self.errors.add :price, :must_be_greater_than_minimum
    end
  end

  def published?
    self.status == PUBLISHED
  end

  def private?
    self.privacy == PRIVATE
  end

  def public?
    self.privacy == PUBLIC
  end

  def draft?
    self.status == DRAFT
  end

  def title_short
    self.title.length > 35 ? "#{title[0..34]}..." : self.title
  end

  def teachers_names
    self.teachers.map(&:full_name).join(", ")
  end

  def average_rate
    if self.course_evaluations.present?
      self.course_evaluations.inject(0) { |sum, el| sum + el.score }.to_f / self.course_evaluations.size
    else
      0
    end
  end

  def free?
    self.price.zero?
  end

  def students
    self.students_purchased + self.students_invited
  end

  def restrict?
    self.privacy == RESTRICT
  end

  def array_of_allowed_emails
    self.allowed_emails.split(",")
  end

  def limited?
    !self.ilimited?
  end

  def ilimited?
    self.available_time == 0
  end

  def cart_items_confirmed
    self.cart_items.payment_confirmed
  end

  def certificate_available?
    self.certificate_available
  end

  def price_with_discount coupon
    if coupon
      self.price - coupon.discount_in_money
    else
      self.price
    end
  end

  def time_available
    self.available_time
  end

  def paid?
    self.price > 0
  end

  def active_users_from_purchases
    User.joins([:purchases, :cart_items])
      .merge(Purchase.payment_confirmed)
      .merge(CartItem.within_validity.where(course_id: self.id))
      .merge(self.students_purchased)
  end

  def expired_users_from_purchases
    User.joins([:purchases, :cart_items])
      .merge(Purchase.payment_confirmed)
      .merge(CartItem.out_of_date)
      .merge(self.students_purchased) - self.active_users_from_purchases
  end

  def confirmed_users_from_purchases
    User.joins(:purchases)
      .merge(Purchase.payment_confirmed)
      .merge(self.students_purchased)
  end

  def pending_users_from_purchases
    User.joins(:purchases)
      .merge(Purchase.pending)
      .merge(self.students_purchased) - self.confirmed_users_from_purchases
  end  

  def canceled_users_from_purchases
    User.joins(:purchases)
      .merge(Purchase.canceled)
      .merge(self.students_purchased) - self.confirmed_users_from_purchases - self.pending_users_from_purchases
  end    

  def active_users_from_invitations
    User.joins(:courses_users).merge(CourseUser.within_validity)
      .merge(CourseUser.where(course_id: self.id))
      .merge(self.students_invited)
  end

  def expired_users_from_invitations
    User.joins(:courses_users)
      .merge(CourseUser.out_of_date)
      .merge(self.students_invited) - self.active_users_from_invitations
  end  

  def active_users
    self.active_users_from_purchases + self.active_users_from_invitations
  end  

  def expired_users
    self.expired_users_from_invitations + self.expired_users_from_purchases
  end
end
