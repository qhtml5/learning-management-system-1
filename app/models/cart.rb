class Cart < ActiveRecord::Base
	default_scope { where(school_id: School.current_id) if School.current_id }

	attr_accessible :coupon, :coupon_id, :courses, :cart_items
	
	has_many :cart_items
	has_many :courses, :through => :cart_items
	has_many :coupons, through: :cart_items

	belongs_to :school

	before_create :save_current_school_id
	before_destroy :empty_cart_items

	def save_current_school_id
		self.school_id = School.current_id
	end

	def total
		total = self.cart_items.map { |c| c.price_with_discount }.sum
		total.to_i
	end

	def total_em_real
		total.to_s.insert(-3, ".").to_f
	end

  def total_greater_than_zero?
  	self.total > 0
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

  def available_to_pay_in_installments?
  	self.maximum_installments > 1
  end

  def empty_cart_items
  	self.cart_items = []
  end
end
