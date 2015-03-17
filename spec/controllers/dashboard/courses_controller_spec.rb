# encoding: utf-8

require 'spec_helper'

describe Dashboard::CoursesController do
	let(:user) { create(:school_admin) }
	let(:school) { user.school }

	before(:each) do
		School.current_id = school.id
		school.courses = create_list(:course, 2, school: school)
		school.save!
		controller.request.stub subdomain: school.subdomain
		sign_in(user)
	end

	describe "GET index" do
		it "should assign @courses if user is not a student" do
			get :index
			assigns(:courses).should == user.courses.to_a
			assigns(:courses).length.should == 2 
		end

		it "should assign @course_items if user is a student" do
			student = create(:student)
			cart_items = school.courses.inject([]) { |r, course| r << create(:cart_item, course: course) }
      create(:purchase_confirmed, user: student, cart_items: cart_items)
			sign_in(student)
			get :index
			assigns(:course_items).to_a.should == cart_items.to_a
		end
	end

	describe "GET show" do
		let(:course) { school.courses.first }

		it "should assign @user" do
			get :show, id: course.id
			assigns(:user).should == user
		end

		it "should assign @course" do
			get :show, id: course.id
			assigns(:course).should == course
		end

		it "should render layout course edit" do
			get :show, id: course.id
			response.should render_template "dashboard/course_edit"
		end
	end

	describe "POST create" do
		let(:course_params) { { title: "Como criar um vídeo" } }
		context "success" do
			it "should set flash notice" do
				post :create, course: course_params
				flash[:notice].should == I18n.t("messages.course.create.success")
			end

			it "should redirect to course index page" do
				post :create, course: course_params
				course = Course.last
				response.should redirect_to dashboard_course_path(course)
			end

			it "should create a course" do
				expect {
					post :create, course: course_params
				}.to change(Course, :count).by(1)
			end

			it "should create a wistia project to school" do
				school.wistia_public_project_id = nil
				school.save!
				Wistia::Project.should_receive(:create).with(
					{
						name: school.subdomain,
						:public => true, 
						anonymousCanUpload: true
					}
				)
				post :create, course: course_params
			end

			it "should link wistia project id with school" do
				Wistia::Project.any_instance.stub(publicId: "xyz123ab")
				post :create, course: course_params
				school.reload
				school.wistia_public_project_id.should == "xyz123ab"
			end
		end

		context "failure" do
			let(:course_params) { { title: "" } }
			before(:each) { post :create, course: course_params }

			it "should set flash alert" do
				flash[:alert].should_not be_nil
			end

			it "should assign @user" do
				assigns(:user).should == user
			end

			it "should reassign @courses" do
				assigns(:courses).should == user.courses
			end

			it "should render index" do
				response.should render_template :index
			end
		end
	end

	describe "PUT update" do
		context "success" do

		end

		context "failure" do
		end
	end

	describe "POST publish" do
		let(:course) { school.courses.first }

		context "success" do
			before(:each) { Course.any_instance.stub save: true }

			it "should set flash notice" do
				post :publish, id: course.id
				flash[:notice].should == I18n.t('messages.course.publish.success')
			end

			it "should redirect to show page if not request referer" do
				post :publish, id: course.id
				response.should redirect_to dashboard_course_path(course)
			end

			it "should redirect to request referer" do
				controller.request.stub(:referer).and_return(edit_basic_info_dashboard_course_path(course))
				post :publish, id: course.id
				response.should redirect_to edit_basic_info_dashboard_course_path(course)
			end
		end

		context "failure" do
			before(:each) { Course.any_instance.stub save: false }
		end
	end

	describe "POST unpublish" do
	end

	describe "GET edit_links_downloads" do
	end

	describe "GET edit_basic_info" do
	end

	describe "GET edit_detailed_info" do
	end

	describe "GET edit_image" do
	end

	describe "GET edit_price_and_coupon" do
	end

	describe "GET edit_privacy" do
	end

	describe "GET edit_teachers" do
	end

	describe "GET library" do
	end
end