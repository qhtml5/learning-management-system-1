#encoding: UTF-8

require 'spec_helper'

describe CourseUser do
  let(:school) { create(:school) }
  before(:each) { School.current_id = school.id }
  let(:course) { create(:course) }
  let(:course_user) { create(:course_user, course: course) }

  describe ".out_of_date?" do
    it "should return false when within_validity? is true" do
      course_user.stub within_validity?: true
      course_user.out_of_date?.should be_false
    end

    it "should return false when within_validity? is false" do
      course_user.stub within_validity?: false
      course_user.out_of_date?.should be_true
    end
  end

  describe ".within_validity?" do
    it "should return true when course is ilimited" do
      course_user.course.update_attribute :available_time, 0
      course_user.within_validity?.should be_true
    end

    it "should return true when its within validity" do
      course_user.course.update_attribute :available_time, 5
      course_user.update_attribute :created_at, Time.now - 4.days
      course_user.within_validity?.should be_true
    end

    it "should return true when its out of date" do
      course_user.course.update_attribute :available_time, 5
      course_user.update_attribute :created_at, Time.now - 6.days
      course_user.within_validity?.should be_false
    end
  end

end