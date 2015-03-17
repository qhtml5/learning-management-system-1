#encoding: UTF-8

require 'spec_helper'

describe Course do

  describe :validations do
    context :presence do
      it { should validate_presence_of(:school) }
      it { should ensure_length_of(:title).is_at_least(5).is_at_most(48) }
    end

    context :length do
      context "when published" do
        let(:school) { create(:school) }
        before(:each) { School.current_id = school.id }
        let(:course) { Course.new(status: "published") }

        it { course.should ensure_length_of(:pitch).is_at_least(5).is_at_most(120) }

        [:content_and_goals, :who_should_attend].each do |attribute|
          it { course.should ensure_length_of(attribute).is_at_least(10).is_at_most(5000) }
        end

        it { course.should ensure_length_of(:description).is_at_least(10).is_at_most(50000) }
      end
    end
  end

  describe :associations do
    it { should have_many(:notifications).dependent(:delete_all) }
    
    [:messages, :cart_items, :purchases, 
      :students_invited, :students_purchased, :lessons_medias, :medias, :course_evaluations].each do |model|
        it { should have_many(model) }
    end

    [:lessons, :coupons].each do |model|
      it { should have_many(model).dependent(:delete_all) }
    end

    it { should belong_to(:school) }
  end

  describe :methods do
    before(:each) do
      school = create(:school)
      School.current_id = school.id
    end
    describe '.price_greater_than_minimum' do
      it "should add error on price if its less than minimum" do
        course = build(:course, price: 2999)
        course.status = "published"
        course.valid?
        course.errors[:price].should_not be_empty
      end
    end

    describe '.published?' do
      it "should return true if status is published" do
        course = Course.new(status: Course::PUBLISHED)
        course.published?.should be_true
      end

      it "should return false if status is not published" do
        course = Course.new(status: Course::DRAFT)
        course.published?.should be_false
      end
    end

    describe '.draft?' do
      it "should return true if status is draft" do
        course = Course.new(status: Course::DRAFT)
        course.draft?.should be_true
      end

      it "should return false if status is not draft" do
        course = Course.new(status: Course::PUBLISHED)
        course.draft?.should be_false
      end
    end

    describe '.public?' do
      it "should return true if privacy is public" do
        course = Course.new(privacy: Course::PUBLIC)
        course.public?.should be_true
      end

      it "should return false if privacy is not public" do
        course = Course.new(privacy: Course::PRIVATE)
        course.public?.should be_false
      end
    end

    describe '.private?' do
      it "should return true if privacy is private" do
        course = Course.new(privacy: Course::PRIVATE)
        course.private?.should be_true
      end

      it "should return false if privacy is not private" do
        course = Course.new(privacy: Course::PUBLIC)
        course.private?.should be_false
      end
    end 

    describe '.title_short' do
      it "should return the first characters of the title" do
        course = Course.new(title: "a"*50)
        course.title_short.should == "#{course.title[0..34]}..."
      end
    end

    describe '.teachers_names' do
      it "should return the list of teachers names" do
        teacher1 = create(:teacher, first_name: "John", last_name: "Boo")
        teacher2 = create(:teacher, first_name: "Bill", last_name: "Clinton")
        course = create(:course, teachers: [teacher1, teacher2])
        course.teachers_names.should == "John Boo, Bill Clinton"
      end
    end

  end

end