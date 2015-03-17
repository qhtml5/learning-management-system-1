#encoding: UTF-8

require "cancan/matchers"
require 'spec_helper'

describe Ability do
  let(:admin_model) { create(:admin) }
  let(:teacher_model) { create(:teacher) }
  let(:student_model) { create(:student) }
  let(:school_admin_model) { create(:school_admin) }
  let(:guest_model) { User.new }

  let(:admin) { Ability.new(admin_model) }
  let(:teacher) { Ability.new(teacher_model) }
  let(:student) { Ability.new(user_model) }
  let(:school_admin) { Ability.new(school_admin_model) }
  let(:guest) { Ability.new(guest_model) }

  describe :admin do
    subject { admin }

    it { should be_able_to(:manage, :all) }
  end

  describe :school_admin do
    subject { school_admin }
    before(:all) {
      @user = school_admin_model
      @school = @user.school
      School.current_id = @school.id
      @school.courses = [create(:course)]
      @course = @school.courses.first
      @another_school = create(:school)
      School.current_id = @another_school.id
      @another_course = create(:course)
      School.current_id = @school.id
    }

    context "School" do
      [:wizard_basic_info, :wizard_choose_plans, 
        :update, :funnel, :crm, :email_marketing, 
        :cart_recovery, :social_media, :course_evaluations,
        :certificate, :show_certificate, :students].each do |action|
          it { should be_able_to(action, @school) }
          it { should_not be_able_to(action, @another_school) }
      end
    end

    context "Layout Configuration" do
      [:index, :update].each do |action|
        it { should be_able_to(action, LayoutConfiguration) }
      end
    end

    context "Course" do
      [:dashboard_index, :dashboard_create].each do |action|
        it { should be_able_to(action, Course) }
      end

      [:dashboard_show, :dashboard_update,
        :dashboard_edit_detailed_info, :dashboard_edit_image,
        :dashboard_edit_promo_video, :dashboard_edit_price_and_coupon, :dashboard_edit_privacy,
        :dashboard_edit_teachers, :dashboard_update_promo_video, :dashboard_medias, :dashboard_edit_links_downloads,
        :dashboard_publish, :dashboard_unpublish].each do |action|
          it { should be_able_to(action, @course) }
          it { should_not be_able_to(action, @another_course) }
      end

      [:dashboard_medias_rename, :dashboard_medias_sort].each do |action|
          it { should be_able_to(action, @course) }
          it { should_not be_able_to(action, @another_course) }  
      end

      [:dashboard_lessons_index, :dashboard_lessons_sort, :dashboard_lessons_rename].each do |action|
          it { should be_able_to(action, @course) }
          it { should_not be_able_to(action, @another_course) }   
      end

      [:submit_message, :submit_answer, :destroy_message].each do |action|
        it { should be_able_to(action, @course) }
        it { should_not be_able_to(action, @another_course) }   
      end

      [:content, :show_media].each do |action|
        it { should be_able_to(action, @course) }
        it { should_not be_able_to(action, @another_course) }   
      end
    end

    context "Lesson" do
      before(:all) {
        @user = school_admin_model
        @school = @user.school
        School.current_id = @school.id
        @school.courses = [create(:course, school: @school)]
        @course = @school.courses.first
        another_school = create(:school)
        @another_course = create(:course, school: another_school)        
        @lesson = @course.lessons.first
        @another_lesson = @another_course.lessons.first
      }
      it { should be_able_to(:manage, @lesson) }
      it { should_not be_able_to(:manage, @another_lesson) }
    end

    context "Media" do
      before(:all) {
        @user = school_admin_model
        @school = @user.school
        School.current_id = @school.id
        @school.courses = [create(:course, school: @school)]
        @course = @school.courses.first
        another_school = create(:school)
        @another_course = create(:course, school: another_school)
        @media = @course.medias.first
        @another_media = @another_course.medias.first
      }
      it { should be_able_to(:manage, @course.medias.first) }
      it { should_not be_able_to(:manage, @another_course.medias.first) }
    end

    context "Coupon" do
      before(:all) do
        @user = school_admin_model
        @school = @user.school
        School.current_id = @school.id
        @course = @school.courses.first
        @another_course = create(:course)
        @coupon = create(:coupon, course: @course)
        @another_coupon = create(:coupon, course: @another_course)
      end
      
      it { should be_able_to(:create, Coupon) }

      [:update, :destroy].each do |action|
        it { should be_able_to(action, @coupon) }
        it { should_not be_able_to(action, @another_coupon) }   
      end
    end
  end

end