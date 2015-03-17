# encoding: utf-8

require 'spec_helper'

describe Dashboard::LessonsController do
	let(:user) { FactoryGirl.create(:school_admin) }
  let(:school) { user.school }
  before(:each) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    controller.request.stub subdomain: school.subdomain
    sign_in(user)
  end
  let(:course) { user.school.courses.first }
	let(:lesson) { course.lessons.first }
	let(:lesson_media) { course.lessons_medias.first }

	describe "PUT rename" do
		it "should rename lesson" do
			put :rename, course_id: course.id, id: lesson.id, lesson: { title: "New lesson name" }
			lesson.reload
			lesson.title.should == "New lesson name"
		end

		it "render nothing" do
			put :rename, course_id: course.id, id: lesson.id, lesson: { title: "New lesson name" }
			response.body.should be_blank
		end
	end

	describe "POST sort" do
		it "should sort lessons" do
			FactoryGirl.create(:lesson, course: course)

			put :sort, course_id: course.id, id: lesson.id, position: "100"
			course.lessons.order(:sequence).last.should == lesson
		end

		it "render nothing" do
			put :sort, course_id: course.id, id: lesson.id, position: "1"
			response.body.should be_blank
		end
	end

end