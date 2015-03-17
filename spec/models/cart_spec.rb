#encoding: UTF-8

require 'spec_helper'

describe Cart do
  before(:each) do
    school = create(:school)
    School.current_id = school.id
  end
  
  describe :associations do
    it { should have_many(:cart_items) }
  end

  describe '.total' do
    it 'should return the sum of cart_item prices' do
      cart = create(:cart)
      cart.cart_items = create_list(:cart_item, 2)
      cart.total.should == cart.cart_items[0].price + cart.cart_items[1].price
    end
  end

  describe '.total_em_real' do
    it 'should return the total in currency format' do
      cart = create(:cart)
      cart.cart_items = [ create(:cart_item, cart: cart, course: create(:course, price: 5000)), 
                          create(:cart_item, cart: cart, course: create(:course, price: 7000))]
      cart.total_em_real.should == 120.0
    end
  end

  describe '.total_greater_than_zero?' do
    it 'should return true when total is greater than zero' do
      cart = create(:cart)
      course = create(:course, price: 5000)
      cart_items = create_list(:cart_item, 2, cart: cart, course: course)
      cart.total_greater_than_zero?.should be_true
    end

    it 'should return false when total is not greater than zero' do
      cart = create(:cart)
      course = build(:course, price: 0)
      course.save validate: false
      cart.cart_items = create_list(:cart_item, 2, cart: cart, course: course)
      cart.total_greater_than_zero?.should be_false
    end
  end

end