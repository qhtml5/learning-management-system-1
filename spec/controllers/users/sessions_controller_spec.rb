# encoding: utf-8

require 'spec_helper'

describe Users::SessionsController do
	let(:school_admin) { create(:school_admin) }
	let(:school) { school_admin.school }
	
	before(:each) do
		School.current_id = school.id
		@request.env["devise.mapping"] = Devise.mappings[:user]
		@request.host = "#{school.subdomain}.example.com"
	end
	let(:course) { create(:course) }
	let(:student) { create(:student) }

	describe "POST create" do
		let(:user_params) do
			{
				email: student.email,
				password: "123456"
			}
		end
		
		it "should create an user sign in notification" do
			expect {
				post :create, user: user_params, course: course
			}.to change(Notification, :count).by(1)
			notification = Notification.last
			notification.sender.should == student
			notification.code.should == Notification::USER_SIGN_IN
			notification.notifiable.should == student
			notification.personal.should be_true
		end

		context "checkout free page login" do
			it "should redirect to content course path" do
				post :create, user: user_params, course: course
				response.should redirect_to content_course_path(course)
			end

			it "should associate course with user" do
				post :create, user: user_params, course: course
				student.reload
				student.courses_invited.should include course
			end

			it "should destroy invitation if present" do
				invitation = create(:invitation, course: course, email: student.email)
				post :create, user: user_params, course: course, invitation: invitation
				Invitation.count.should == 0
			end					
		end

		context "restrict course page login" do
			it "should redirect to add to cart page" do
				post :create, user: user_params, course: course, restrict: true
				response.should redirect_to add_to_cart_course_path(course)
			end
		end
	end

end