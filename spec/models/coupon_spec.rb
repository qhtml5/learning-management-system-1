require 'spec_helper'

describe Coupon do  
  describe :validations do
    context :presence do
      [:name, :expiration_date, :quantity, :course].each do |attribute|
        it { should validate_presence_of(attribute) }
      end
    end

    context :length do
      #TODO Greater than and less than
      it { should validate_numericality_of(:discount).only_integer }
    end
  end

  describe :associations do
    it { should have_many(:cart_items) }
    it { should have_many(:purchases) }
    it { should belong_to(:course) }
  end

  describe :methods do
    before(:each) do
      school = create(:school)
      School.current_id = school.id
    end
    describe '.expiration_date_in_the_future' do
      it "should add error if expiration date is not in the future" do
      end
    end

    describe '.update_quantity_left' do
      it "should update quantity_left with quantity minus confirmed purchases after saving coupon" do
        coupon = create(:coupon, quantity: 100)
        cart_items = create_list(:cart_item, 3, coupon: coupon, course: coupon.course)
        purchase = create_list(:purchase_confirmed, 2, cart_items: cart_items)
        coupon.save!
        coupon.quantity_left.should == 100 - 3
      end

      it "should not update not confirmed purchases" do
        coupon = create(:coupon, quantity: 100)
        cart_items = create_list(:cart_item, 3, coupon: coupon, course: coupon.course)
        purchase = create_list(:purchase, 2, cart_items: cart_items)
        coupon.save!
        coupon.quantity_left.should == 100
      end
    end

    describe '.discount_in_money' do
      it "should return the discount in money" do
        course = create(:course, price: 5000)
        coupon = create(:coupon, discount: 10, course: course)
        coupon.discount_in_money.should == 500.0
      end
    end

    describe '.active?' do
      it "should return true if has quantity left and did not expired yet" do
        coupon = create(:coupon)
        coupon.active?.should be_true
      end

      it "should return false if quantity left is 0 and did not expired yet" do
        coupon = create(:coupon, quantity: 2)
        cart_items = create_list(:cart_item, 3, coupon: coupon, course: coupon.course)
        purchase = create_list(:purchase_confirmed, 2, cart_items: cart_items)
        coupon.save!
        coupon.active?.should be_false
      end

      it "should return false if has quantity left and expired" do
        coupon = create(:coupon)
        coupon.update_attribute :expiration_date, Time.now - 1.day
        coupon.active?.should be_false
      end
    end

    describe '.active?' do
      it "should return true if has quantity left and did not expired yet" do
        coupon = create(:coupon)
        coupon.inactive?.should be_false
      end

      it "should return false if quantity left is 0 and did not expired yet" do
        coupon = create(:coupon, quantity: 2)
        cart_items = create_list(:cart_item, 3, coupon: coupon, course: coupon.course)
        purchase = create_list(:purchase_confirmed, 2, cart_items: cart_items)
        coupon.save!
        coupon.inactive?.should be_true
      end

      it "should return false if has quantity left and expired" do
        coupon = create(:coupon)
        coupon.update_attribute :expiration_date, Time.now - 1.day
        coupon.inactive?.should be_true
      end
    end
  end

end
