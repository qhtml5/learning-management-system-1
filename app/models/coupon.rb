class Coupon < ActiveRecord::Base
  attr_accessible :name, :discount, :expiration_date, :quantity, :quantity_left, :automatic

  has_many :cart_items
  has_many :purchases, through: :cart_items
  
  belongs_to :course

  scope :active, where("expiration_date > ? AND quantity_left > 0", Time.now)
  scope :inactive, where("expiration_date < ? OR quantity_left <= 0", Time.now)
  scope :expired, where("expiration_date < ?", Time.now)
  scope :sold_out, where("quantity <= 0")
  scope :not_automatic, where(automatic: false)
  scope :automatic, where(automatic: true)

  validates :name, :presence => true, :length => { :maximum => 36 }
  validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, only_integer: true }
  validates :expiration_date, :presence => true
  validates :quantity, :presence => true, :numericality => true
  validates :course, presence: true
  validate :expiration_date_in_the_future

  before_save :update_quantity_left

  def expiration_date_in_the_future
    if self.expiration_date
      self.errors.add :expiration_date, :must_be_in_the_future unless self.expiration_date > Time.now
    end
  end

  def update_quantity_left
    if self.new_record?
      self.quantity_left = self.quantity
    else 
      self.quantity_left = self.quantity - self.purchases.payment_confirmed.length
    end
  end

  def discount_in_money
    self.course.price * (self.discount.to_f / 100)
  end

  def active?
    (self.quantity_left > 0) && (self.expiration_date > Time.now)
  end

  def inactive?
    !self.active?
  end
end
