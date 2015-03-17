#encoding: UTF-8

require 'spec_helper'

describe Purchase do

  describe :validations do
    context :presence do
      [:user, :cart_items, :identificator].each do |attribute|
        it { should validate_presence_of(attribute) }
      end
    end

    context '.payment_status_change' do
      before(:each) { School.current_id = create(:school).id }

      it "should save purchase when status change from pending to confirmed" do
        purchase = create(:purchase)
        purchase.payment_status = Purchase::CONFIRMED
        purchase.should be_valid
      end
      
      it "should not save purchase when status change from confirmed to pending" do
        purchase = create(:purchase_confirmed)
        purchase.payment_status = Purchase::CANCELED
        purchase.should_not be_valid
      end
    end
  end

  describe :associations do
    it { should have_many(:notifications).dependent(:delete_all) }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:courses) }
    it { should belong_to(:user) }
  end 

  describe :methods do
    before(:each) do
      school = create(:school)
      School.current_id = school.id
    end

    describe '.update_cart_items_course_prices' do
      it "should update all cart items with it's course prices" do
        purchase = create(:purchase, cart_items: create_list(:cart_item, 2))
        purchase.cart_items.each do |cart_item|
          cart_item.price.should == cart_item.course.price
        end
      end
    end
    
    describe '.total' do
      it 'should return the sum of cart_item prices' do
        purchase = create(:purchase, cart_items: create_list(:cart_item, 2))
        purchase.total.should == purchase.cart_items[0].price + purchase.cart_items[1].price
      end
    end  

    describe '.pending?' do
      it "should return true if purchase has payment_status 'Concluido'" do
        purchase = Purchase.new(payment_status: "Iniciado")
        purchase.pending?.should be_true
      end

      it "should return false if purchase has payment_status 'Concluido'" do
        purchase = Purchase.new(payment_status: "Concluido")
        purchase.pending?.should be_false
      end

      it "should return false if purchase has payment_status 'Autorizado'" do
        purchase = Purchase.new(payment_status: "Autorizado")
        purchase.pending?.should be_false
      end
    end

    describe '.save_validity_date' do
      it "should update cart items validity date" do
        cart_items = create_list(:cart_item, 3)
        purchase = create(:purchase_confirmed, cart_items: cart_items)
        purchase.save_validity_date
        cart_items.each do |cart_item|
          cart_item.confirmed_at.should_not be_nil
        end
      end
    end

  end

end