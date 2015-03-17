#coding: utf-8

class Purchase < ActiveRecord::Base
  default_scope { where(school_id: School.current_id) if School.current_id }

  PAYMENT_STATUS = { "1" => "Autorizado", "2" => "Iniciado", "3" => "Boleto Impresso", 
    "4" => "Concluido", "5" => "Cancelado", "6" => "Em Analise", "7" => "Estornado", "9" => "Reembolsado" }

  CONFIRMED_STATUS = ["Concluido", "Autorizado", "Liberado"]
  PENDING_STATUS = ["Iniciado", "Boleto Impresso", "Cancelado", 
    "Em Analise", "Estornado", "Reembolsado", "EmAnalise"]

  AUTHORIZED = "Autorizado"
  LIBERATED = "Liberado"
  CONFIRMED = "Concluido"
  INITIATED = "Iniciado"
  ANALYSING = "Em Analise"
  CANCELED = "Cancelado"

  attr_accessible :status, :moip_tax, :amount_paid, :moip_code, :payment_status,
                  :courses, :payment_type, :institution, :identificator, :user, 
                  :token, :sent_new_email, :sent_confirmation_email, :cart_items, :commission

  belongs_to :user
  belongs_to :school

  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :cart_items, dependent: :destroy
  has_many :coupons, through: :cart_items
  has_many :courses, through: :cart_items
  has_many :teachers, through: :courses

  validates :user, :presence => true
  validates :cart_items, :presence => true
  validates :identificator, :uniqueness => true, :presence => true
  validate :payment_status_change

  scope :payment_confirmed, where(:payment_status => ["Concluido", "Autorizado", "Liberado"])
  scope :pending, where(:payment_status => ["Iniciado", "Em Analise", "Boleto Impresso"])
  scope :canceled, where(:payment_status => ["Cancelado", "Estornado", "Reembolsado"])
  scope :not_initiated, where(:payment_status => ["Aguardando Pagamento"])
  scope :from_user, lambda { |user_id| where(:user_id => user_id) }
  scope :with_course, lambda { |course_id| joins(:courses).where(:courses => { :id => course_id }) }
  scope :between, lambda { |start_date, end_date| 
    where("purchases.created_at between ? and ?", start_date.to_datetime.change(:hour => 00, :min => 00, :sec => 00), end_date.to_datetime.change(:hour => 23, :min => 59, :sec => 59)) 
  }
  scope :paid_with_credit_card, where(payment_type: ["CartaoDeCredito", "CartaoCredito"])
  scope :paid_with_online_debit, where(payment_type: "DebitoBancario")
  scope :paid_with_billet, where(payment_type: "BoletoBancario")
  scope :with_coupon, lambda { |coupon_id| joins(:coupons).where(coupons: { id: coupon_id }) }

  # validates :payment_status, :code, :message, :presence => true

  # validates :code, :moip_code, :moip_tax, :amount_paid, :numericality => true, :allow_blank => true

  before_create :save_current_school_id
  after_save :save_coupons

  def save_current_school_id
    self.school_id = School.current_id
  end

  def total
    total = self.cart_items.map { |ci| ci.price_with_discount }.sum
    total.to_i
  end

  def authorized?
    self.payment_status == AUTHORIZED
  end

  def total_with_fee
    self.amount_paid.present? ? self.amount_paid : self.total
  end

  def fee
    self.amount_paid ? self.amount_paid - self.total : 0
  end

  def pending?
    PENDING_STATUS.include? self.payment_status
  end

  def confirmed?
    CONFIRMED_STATUS.include? self.payment_status
  end

  def available_to_pay?
    PENDING_STATUS.include? self.payment_status
  end

  def save_coupons
    self.coupons.each(&:save)
  end

  def register_on_rdstation status
    self.courses.each do |course|
      self.user.register_on_rdstation "#{status}_#{course.slug}"
    end
  end

  def date_within_the_validity?
    Time.now < self.created_at + self.course.available_time.days
  end

  def out_of_date?
    !date_within_the_validity?
  end

  def total_liquid
    self.amount_paid - self.moip_tax if self.amount_paid && self.moip_tax
  end

  def courses_titles
    self.cart_items.map do |ci| 
      course_title = ci.course.title
      course_title += " (#{ci.coupon.name})" if ci.coupon.present?
      course_title
    end.join(", ")
  end

  def maximum_installments
    result = self.total / 500.0
    if result >= 12
      12
    elsif result.to_i == 0
      1
    else
      result.to_i
    end
  end

  def course_names
    self.courses.map(&:title).join(", ")
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Identificador","Cursos", "Data","Valor Pago","Status","Nome Completo","Email",
                "Telefone", "Endereço","CPF","Empresa","Cargo"]
      self.all.each do |purchase|
        user = purchase.user
        csv << [
          purchase.identificator + "\n",
          purchase.course_names,
          purchase.created_at.strftime('%d/%B/%Y %H:%M'),
          purchase.amount_paid.em_real,
          purchase.payment_status,
          user.full_name,
          user.email,
          user.phone_number + "\n",
          user.full_address,
          user.cpf,
          user.company,
          user.function
        ]
      end
    end
  end  

  def create_pending_notification
    self.create_notification Notification::PURCHASE_USER_PENDING, Notification::PURCHASE_PENDING
  end

  def create_liberated_notification
    self.create_notification Notification::PURCHASE_USER_LIBERATED, Notification::PURCHASE_LIBERATED
  end

  def create_confirmed_notification
    self.create_notification Notification::PURCHASE_USER_CONFIRMED, Notification::PURCHASE_CONFIRMED
  end

  def create_notification user_code, team_code
    Notification.create(
      receiver: self.user, 
      code: user_code, 
      notifiable: self
    )

    Notification.create_list(
      sender: self.user,
      receivers: self.school.admins + self.teachers,
      code: team_code,
      notifiable: self
    )
  end

  def save_validity_date
    self.cart_items.each do |cart_item|
      cart_item.update_attribute :confirmed_at, Time.now
    end
  end  

  def payment_status_change
    if CONFIRMED_STATUS.include?(self.payment_status_was) && PENDING_STATUS.include?(self.payment_status)
      self.errors.add :payment_status, :cannot_change_from_confirmed_to_pending
    end
  end
    
end

