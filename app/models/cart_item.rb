class CartItem < ActiveRecord::Base	
	attr_accessible :course, :coupon, :cart, :created_at, :confirmed_at

	has_many :notifications, as: :notifiable, dependent: :delete_all

	belongs_to :cart
	belongs_to :course
	belongs_to :coupon
	belongs_to :purchase
  has_one :user, through: :purchase

  scope :payment_confirmed, joins(:purchase).
                              where(:purchases => { :payment_status => ["Concluido","Autorizado"] })
  scope :payment_pending, joins(:purchase).
                            where("purchases.payment_status not in (?)", ["Concluido","Autorizado"])
  scope :pending, joins(:purchase).where(purchases: { :payment_status => ["Iniciado", "Em Analise", "Boleto Impresso"] })
  scope :canceled, joins(:purchase).where(purchases: { :payment_status => ["Cancelado", "Estornado", "Reembolsado"] })

	scope :within_validity, payment_confirmed.joins(:course).where(
    "DATE_ADD(cart_items.confirmed_at, INTERVAL courses.available_time DAY) > ? OR courses.available_time = 0", Time.now
  )
  scope :out_of_date, payment_confirmed.joins(:course).where(
    "courses.available_time <> 0 AND DATE_ADD(cart_items.confirmed_at, INTERVAL courses.available_time DAY) < ?", Time.now
  )  
  scope :between, lambda { |start_date, end_date| 
    where("cart_items.created_at between ? and ?", start_date.to_datetime.change(:hour => 00, :min => 00, :sec => 00), end_date.to_datetime.change(:hour => 23, :min => 59, :sec => 59)) 
  }
  scope :published, joins(:course).where(courses: { :status => "published" })                            
  scope :with_purchase, where("purchase_id IS NOT NULL")
  scope :with_price, where("price > 0")

  scope :paid_with_credit_card, joins(:purchase).where(purchases: { payment_type: ["CartaoDeCredito", "CartaoCredito"] })
  scope :paid_with_online_debit, joins(:purchase).where(purchases: { payment_type: "DebitoBancario" })
  scope :paid_with_billet, joins(:purchase).where(purchases: { payment_type: "BoletoBancario" })

	validates :course, presence: true
	validate :cart_or_purchase_presence

  before_create :save_price

	def cart_or_purchase_presence
		self.errors.add :cart, :must_have_cart_or_purchase unless self.cart.present? || self.purchase.present?
	end

  def out_of_date?
    !self.within_validity?
  end

  def within_validity?
    if self.expires_at
      self.expires_at > Time.now
    else
      true
    end
  end

  def expires_at
    self.confirmed_at + self.course.available_time.days if self.course.limited? && self.confirmed_at
  end

  def status
  	if self.purchase.confirmed?
  		self.within_validity? ? :within_validity : :out_of_date
  	else
  		:pending
  	end
  end

  def limited?
    self.course.limited? && self.confirmed_at
  end

  def amount_paid
    self.purchase.amount_paid
  end

  def moip_tax
    (self.purchase.moip_tax / self.purchase.total) * self.price
  end

  def price_with_discount
    if self.coupon.present?
      self.price - self.coupon.discount_in_money
    else
      self.price
    end
	end

  def save_price
    self.price = self.course.price
  end

end
