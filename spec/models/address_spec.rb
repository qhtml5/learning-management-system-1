#encoding: UTF-8

require 'spec_helper'

describe Address do

  describe :validations do
    context "when user is purchasing" do
      before(:each) do
        User.current_status = :purchasing
      end

      context :presence do
        [:street, :number, :district, :city, :state, :zip_code].each do |attribute|
          it { should validate_presence_of(attribute) }
        end
      end

      context :length do
        [:street, :district, :city].each do |attribute|
          it { should ensure_length_of(attribute).is_at_least(3).is_at_most(200) }
        end

        it { should ensure_length_of(:number).is_at_least(1).is_at_most(50) }
        it { should ensure_length_of(:state).is_equal_to(2) }
        it { should ensure_length_of(:zip_code) }
      end
    end

    context "when user is not purchasing" do
      before(:each) do
        User.current_status = nil
      end

      context :presence do
        [:street, :number, :district, :city, :state, :zip_code].each do |attribute|
          it { should_not validate_presence_of(attribute) }
        end
      end
    end
  end

  describe :associations do
    it { should belong_to(:user) }
  end

	describe '.remove_masks' do
		it 'should remove any non numeric char' do
  		address = FactoryGirl.build :address
  		address.zip_code = "24800-000"
  		address.save!
  		address.zip_code.should == "24800000"
  	end
	end

  describe ".purchasing?" do
    it "should return true if user current status is :purchasing" do
      address = create(:address)
      User.current_status = :purchasing
      address.purchasing?.should == true
    end
  end

end