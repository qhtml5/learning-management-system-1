#coding: utf-8

class School < ActiveRecord::Base
  
  BASIC = 'basic'
  TRIAL = 'trial'
  CUSTOM = 'high'
  
  PLANS = { "25% comissão" => "basic", "Trial" => "trial", "Iniciante" => "starter", "Básico" => "bronze",
            "Intermediário" => "silver", "Avançado" => "gold", "Personalizado" => "high" }

  NEW_PLANS = { "Iniciante" => "starter", "Básico" => "bronze",
            "Intermediário" => "silver", "Avançado" => "gold", "Personalizado" => "high" }  

  PAYMENT_FORMS_BR = { "Cartão de Crédito" => :credit_card, "Boleto Bancário" => :billet,
                        "Débito Online" => :online_debit}

  PRICING_STYLE_INSTALLMENTS = 1
  PRICING_STYLE_FULL = 2
  
  extend FriendlyId
  friendly_id :slug, use: :slugged
  
  attr_accessible :about_us, :facebook, :twitter, :name, :site, :slug, :subdomain, 
                  :status, :domain, :moip_login, :plan, :ga_tracking_id, :token_rdstation,
                  :adroll_adv_id, :adroll_pix_id, :email, :phone, :cart_recovery,
                  :accept_credit_card, :accept_online_debit, :accept_billet, :pricing_style,
                  :notification_configuration_attributes, :automatic_confirmation, :use_custom_domain,
                  :footer_info, :introduction_info
                  
  cattr_accessor :current_id
  
  has_one :module_configuration
  has_one :layout_configuration
  has_one :notification_configuration
  accepts_nested_attributes_for :notification_configuration

  has_many :courses
  has_many :students_invited, through: :courses_users, source: :user, conditions: { role: "student" }, uniq: true
  has_many :lessons, through: :courses
  has_many :lessons_medias, through: :lessons
  has_many :medias, through: :lessons_medias
  has_many :invitations
  has_many :users
  has_many :purchases
  has_many :students_purchased_confirmed, through: :purchases, 
                      source: :user, 
                      uniq: true, 
                      conditions: { :purchases => { :payment_status => Purchase::CONFIRMED_STATUS } }
  has_many :students_purchased_pending, through: :purchases, 
                      source: :user, 
                      uniq: true, 
                      conditions: { :purchases => { :payment_status => Purchase::PENDING_STATUS } }                      
  has_many :students_purchased, through: :purchases, 
                      source: :user, 
                      uniq: true
  has_many :leads

  has_many :students, class_name: "User", conditions: { role: "student" }, uniq: true
  has_many :admins, class_name: "User", conditions: { role: "school_admin" }, uniq: true
  has_many :teachers, class_name: "User", conditions: { role: "teacher" }, uniq: true
  has_many :edools_admins, class_name: "User", conditions: { role: "admin" }, uniq: true

  validates :name, presence: true
  validates :subdomain, uniqueness: true, 
                        presence: true, 
                        length: { minimum: 3, maximum: 30 }, 
                        format: /^[a-z\d._]+(-[a-z\d._]+)*$/i
  validates :moip_login, length: { minimum: 6, maximum: 30 }, 
                         allow_blank: true
  validates :domain, presence: true, if: :use_custom_domain?

  validate :validates_moip_login_format
  validate :validates_payment_forms

  scope :created_yesterday, where("schools.created_at between ? and ?", Date.yesterday.to_datetime.change(:hour => 00, :min => 00, :sec => 00), Date.yesterday.to_datetime.change(:hour => 23, :min => 59, :sec => 59)) 
  scope :trial, where(plan: TRIAL)
  scope :two_days_to_end, where("schools.created_at between ? and ?", (Date.today - 14.days).to_datetime.change(:hour => 00, :min => 00, :sec => 00), (Date.today - 14.days).to_datetime.change(:hour => 23, :min => 59, :sec => 59)) 
  scope :trial_ended, where("schools.created_at between ? and ?", (Date.today - 16.days).to_datetime.change(:hour => 00, :min => 00, :sec => 00), (Date.today - 16.days).to_datetime.change(:hour => 23, :min => 59, :sec => 59)) 


  before_create :build_layout
  before_create :build_module

  def users_and_leads
    self.users.not_admins + self.leads
  end

  def build_layout
    self.build_layout_configuration
  end

  def build_module
    self.build_module_configuration
  end

  def use_custom_domain?
    self.use_custom_domain
  end

  def available_plans
    if self.plan == BASIC
      School::NEW_PLANS.merge({"25% comissão" => "basic"})
    elsif self.plan == TRIAL
      School::NEW_PLANS.merge({"Trial" => "trial"})
    else
      School::NEW_PLANS
    end
  end

  def validates_moip_login_format
    if self.moip_login_changed?
      begin
        @payer = MyMoip::Payer.new(
          :id => self.id,
          :name => "Bizstart",
          :email => "bizstart@gmail.com",
          :address_street => "Rua Street",
          :address_street_number => "123",
          :address_street_extra => "Complemento",
          :address_neighbourhood => "Distrito",
          :address_city => "Cidade",
          :address_state => "RJ",
          :address_country => "BRA",
          :address_cep => "24812128",
          :address_phone => "2498761234"
        ) 
        commissions = [MyMoip::Commission.new(
          reason: 'Comissao Edools Plano Básico',
          receiver_login: self.moip_login,
          percentage_value: 0.25
        )]
        @instruction = MyMoip::Instruction.new(
          :values => [100.00],
          :id => "#{Time.now.strftime("%Y%m%d%H%M%s")}#{rand(100)}",
          :payer => @payer,
          :payment_reason => "Cadastro de login MoIP",
          commissions: commissions
        )
        transparent_request = MyMoip::TransparentRequest.new("bizstart")
        transparent_request.api_call(@instruction)

        if transparent_request.response["EnviarInstrucaoUnicaResponse"]["Resposta"]["Erro"].present?
          self.errors.add :moip_login, transparent_request.response["EnviarInstrucaoUnicaResponse"]["Resposta"]["Erro"]["__content__"]
        end
      rescue
      end
    end
  end
  
  def commissioned_plan?
    self.plan == School::BASIC
  end

  def team
    self.admins + self.teachers + self.edools_admins
  end

  def owner
    self.admins.first
  end
  
  def wistia_media? hash
    self.medias.where(:wistia_hashed_id => hash).present?
  end

  def validates_payment_forms
    if [self.accept_billet, self.accept_credit_card, self.accept_online_debit].uniq == [false]
      self.errors.add :accept_credit_card, "Sua escola deve aceitar ao menos um meio de pagamento"
    end
  end

  def accepted_payment_forms
    result = []
    result << :credit_card if self.accept_credit_card
    result << :online_debit if self.accept_online_debit
    result << :billet if self.accept_billet
    result
  end

  def accepts_payment_form? payment_form
    self.accepted_payment_forms.include? payment_form
  end

  def pricing_style_full?
    self.pricing_style == PRICING_STYLE_FULL
  end

  def self.send_day_one_mail
    School.created_yesterday.each do |school|
      SchoolMailer.day_one_help(school).deliver
    end
  end

  def self.send_two_days_to_end_trial_mail
    School.trial.two_days_to_end.each do |school|
      SchoolMailer.two_days_to_end_trial(school).deliver
    end
  end

  def self.send_end_trial_mail
    School.trial.trial_ended.each do |school|
      SchoolMailer.end_trial(school).deliver
    end
  end  

  def default_email
    self.email.present? ? self.email : self.owner.email
  end

  def active_users_from_purchases
    self.students.joins([:purchases, :cart_items])
      .merge(Purchase.payment_confirmed).merge(CartItem.within_validity)
  end

  def expired_users_from_purchases
    self.students.joins([:purchases, :cart_items])
      .merge(Purchase.payment_confirmed).merge(CartItem.out_of_date) - self.active_users_from_purchases
  end

  def confirmed_users_from_purchases
    self.students.joins(:purchases).merge(Purchase.payment_confirmed)
  end

  def pending_users_from_purchases
    self.students.joins(:purchases).merge(Purchase.pending) - self.confirmed_users_from_purchases
  end  

  def canceled_users_from_purchases
    self.students.joins(:purchases).merge(Purchase.canceled) - self.confirmed_users_from_purchases - 
      self.pending_users_from_purchases
  end    

  def active_users_from_invitations
    self.students.joins(:courses_users).merge(CourseUser.within_validity)
  end

  def expired_users_from_invitations
    self.students.joins(:courses_users).merge(CourseUser.out_of_date) - self.active_users_from_invitations
  end  

  def active_users
    self.active_users_from_purchases + self.active_users_from_invitations
  end  

  def expired_users
    self.expired_users_from_invitations + self.expired_users_from_purchases
  end

end
