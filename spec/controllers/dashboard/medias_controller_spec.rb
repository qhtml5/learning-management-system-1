# encoding: utf-8

require 'spec_helper'

describe Dashboard::MediasController do
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
	let(:media) { course.medias.first }
	let(:lesson_media) { course.lessons_medias.first }

	describe "PUT rename" do
		it "should rename media" do
			put :rename, course_id: course.id, id: media.id, media: { title: "New media name" }
			media.reload
			media.title.should == "New media name"
		end

		it "render nothing" do
			put :rename, course_id: course.id, id: media.id, media: { title: "New media name" }
			response.body.should be_blank
		end
	end

	describe "POST sort" do
		it "should sort medias" do
			lesson = course.lessons.first
			FactoryGirl.create(:lesson_media, lesson: lesson, media: FactoryGirl.build(:media))

			put :sort, course_id: course.id, id: lesson_media.id, position: "100"
			lesson.reload
			lesson.lessons_medias.order(:sequence).last.should == lesson_media
		end

		it "render nothing" do
			put :sort, course_id: course.id, id: lesson_media.id, position: "1"
			response.body.should be_blank
		end
	end

end