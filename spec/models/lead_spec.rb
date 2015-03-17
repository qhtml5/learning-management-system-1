require 'spec_helper'

describe Lead do
  describe :validations do
    context :presence do
      let(:school) { create(:school) }
      before(:each) { School.current_id = school.id }

      it "should validate uniqueness of email with the same course_id" do
        course = create(:course)
      	lead = create(:lead, email: "john@gmail.com", course: course)
      	lead2 = build(:lead, email: "john@gmail.com", course: course)
        lead2.valid?
      	lead2.errors[:email].should_not be_empty
      end

      it "should not validate uniqueness of email with differente course_id" do
      	course = create(:course)
        course2 = create(:course)
        lead = create(:lead, email: "john@gmail.com", course: course)
        lead2 = build(:lead, email: "john@gmail.com", course: course2)
        lead2.valid?
      	lead2.errors[:email].should be_empty
      end
    end
 	end
end
