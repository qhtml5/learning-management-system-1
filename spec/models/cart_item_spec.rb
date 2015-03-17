#encoding: UTF-8

require 'spec_helper'

describe CartItem do

  describe :validations do
    context :presence do
      it { should validate_presence_of(:course) }
    end
  end

  describe :associations do
    it { should have_many(:notifications).dependent(:delete_all) }
    
    [:cart, :course, :coupon, :purchase].each do |model|
      it { should belong_to(model) }
    end
  end

  describe :methods do
    before(:each) do
      school = create(:school)
      School.current_id = school.id
    end

    describe ".cart_or_purchase_presence" do
      it "should_not add error if cart or purchase associated" do
        cart_item = build(:cart_item)
        cart_item.valid?
        cart_item.errors[:cart].should be_empty
      end

      it "should add error unless associated to cart or purchase" do
        cart_item = build(:cart_item, cart: nil, purchase: nil)
        cart_item.valid?
        cart_item.errors[:cart].should_not be_empty
      end
    end

    describe ".price_with_discount" do
      it "should return course price minus coupon discount if coupon is present" do
        cart_item = create(:cart_item, coupon: build(:coupon))
        course = cart_item.course
        coupon = cart_item.coupon
        cart_item.price_with_discount.should == course.price - coupon.discount_in_money
      end
    end

    describe ".save_price" do
      it "should return course price if coupon is not present" do
        cart_item = create(:cart_item)
        course = cart_item.course
        cart_item.price.should == course.price
      end
    end

    describe ".out_of_date?" do
      let(:cart_item) { create(:cart_item) }

      it "should return false when within_validity? is true" do
        cart_item.stub within_validity?: true
        cart_item.out_of_date?.should be_false
      end

      it "should return false when within_validity? is false" do
        cart_item.stub within_validity?: false
        cart_item.out_of_date?.should be_true
      end
    end

    describe ".within_validity?" do
      let(:cart_item) { create(:cart_item) }

      it "should return true when course is ilimited" do
        cart_item.course.update_attribute :available_time, 0
        cart_item.within_validity?.should be_true
      end

      it "should return true when its within validity" do
        cart_item.course.update_attribute :available_time, 5
        cart_item.update_attribute :confirmed_at, Time.now - 4.days
        cart_item.within_validity?.should be_true
      end

      it "should return true when its out of date" do
        cart_item.course.update_attribute :available_time, 5
        cart_item.update_attribute :confirmed_at, Time.now - 6.days
        cart_item.within_validity?.should be_false
      end
    end
  end

end