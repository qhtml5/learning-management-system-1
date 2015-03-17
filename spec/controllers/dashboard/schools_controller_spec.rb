# encoding: utf-8

require 'spec_helper'

describe Dashboard::SchoolsController do
	let(:user) { FactoryGirl.create(:school_admin) }
	let(:school) { user.school }
	before(:each) do
		School.current_id = school.id
		school.courses = [FactoryGirl.create(:course)]
		school.save!
		controller.request.stub subdomain: school.subdomain
		sign_in(user)
	end
	let(:course) { school.courses.first }

	describe "GET edit_basic_info" do
		before(:each) { get :edit_basic_info }

		it "should assign @user" do
			assigns(:user).should == user
		end
		it "should assign @school" do
			assigns(:school).should == user.school
		end 
		it "should set status to flash" do
			flash[:school_status].should == :edit_basic_info
		end
	end

	describe "GET wizard_basic_info" do
		def do_action
			get :wizard_basic_info
		end

		it "should assign @user" do
			do_action 
			assigns(:user).should == user
		end
		it "should assign @school" do
			do_action 
			assigns(:school).should == user.school
		end 

		it "should instantiate a new school if user does not have one" do
			user.school = nil
			user.save!
			do_action
			assigns(:school).should be_an_instance_of(School)
		end
	end

	describe "GET wizard_choose_plans" do
		before(:each) { get :wizard_choose_plans }

		it "should assign @user" do
			assigns(:user).should == user
		end
		it "should assign @school" do
			assigns(:school).should == user.school
		end 
		it "should set status to flash" do
			flash[:school_status].should == :wizard_choose_plans
		end
	end

	describe "GET course_evaluations" do
		before(:each) { get :course_evaluations }

		it "should assign @user" do
			assigns(:user).should == user
		end
		it "should assign @school" do
			assigns(:school).should == user.school
		end 
		it "should assign @course" do
			assigns(:courses).should == user.school.courses
		end
	end

	describe "POST create" do
		context "success" do
			let(:school_attributes) { { name: "Endeavor", subdomain: "endeavor" } }

			it "should set flash notice" do
				post :create, school: school_attributes
				flash[:notice].should == "Escola criada com sucesso! Está iniciando agora seu período de 15 dias de teste gratuito com todas as funcionalidades liberadas."
			end

			it "should redirect to dashboard courses page" do
				post :create, school: school_attributes
				response.should redirect_to dashboard_courses_path(subdomain: "endeavor", code: user.encrypted_password)
			end
		end

		context "failure" do
			let(:school_attributes) { { name: "Endeavor", subdomain: "" } }

			it "should render wizard basic info page" do
				post :create, school: school_attributes
				response.should render_template :wizard_basic_info
			end

		end
	end

	describe "PUT update" do
		context "success" do
			it "should redirect to dashboard courses when came from wizard_choose_plans" do
				controller.stub_chain(:flash, :[]).with(:school_status).and_return(:wizard_choose_plans)
				controller.stub_chain(:flash, :[]=).and_return(true)
				put :update, id: user.school.id, school: { plan: "middle" }
				response.should redirect_to dashboard_courses_path
				# flash[:notice].should == "Parabéns! Sua escola foi criada com sucesso!"
			end

			it "should send notification to school owner when came from wizard_choose_plans" do
				controller.stub_chain(:flash, :[]).with(:school_status).and_return(:wizard_choose_plans)
				controller.stub_chain(:flash, :[]=).and_return(true)
				Notification.should_receive(:create).with do |*args|
          notification = args.pop
          notification[:receiver].should == user
          notification[:code].should == Notification::SCHOOL_PLAN_CHOOSE
          notification[:notifiable].should == user.school
          true
        end
				put :update, id: user.school.id, school: { plan: "middle" }
			end

			it "should redirect to configurations when came from configurations" do
				controller.stub_chain(:flash, :[]).with(:school_status).and_return(:configurations_general)
				controller.stub_chain(:flash, :[]=).and_return(true)
				put :update, id: user.school.id, school: { plan: "middle" }
				response.should redirect_to configurations_general_dashboard_schools_path
			end

			it "should redirect to edit_basic_info when came from edit_basic_info" do
				controller.stub_chain(:flash, :[]).with(:school_status).and_return(:edit_basic_info)
				controller.stub_chain(:flash, :[]=).and_return(true)
				put :update, id: user.school.id, school: { plan: "middle" }
				response.should redirect_to edit_basic_info_dashboard_schools_path
				# flash[:notice].should == "Informações atualizadas com sucesso."
			end

			it "should redirect to previous page when came from any other page" do
				path = edit_basic_info_dashboard_schools_path
				controller.request.stub(:referer).and_return(path)
				put :update, id: user.school.id, school: { plan: "middle" }
				flash[:notice].should == I18n.t('messages.school.update.success')
				response.should redirect_to path
			end
		end

		context "failure" do
			it "should redirect to flash school status action" do
				controller.stub_chain(:flash, :[]).with(:school_status).and_return(:edit_basic_info)
				controller.stub_chain(:flash, :[]=).and_return(:edit_basic_info)
				put :update, id: user.school.id, school: { name: "" }
				response.should render_template :edit_basic_info
			end

			it "should render template create_school if wizard step" do
				controller.stub_chain(:flash, :[]).with(:school_status).and_return(:wizard_basic_info)
				controller.stub_chain(:flash, :[]=).and_return(:wizard_basic_info)
				put :update, id: user.school.id, school: { name: "" }
				response.should render_template :wizard_basic_info
				response.should render_template "dashboard/create_school"
			end 
		end
	end

	describe "GET show_certificate" do
		let(:student) { create(:student, school: school) }

		before(:each) do
			cart_items = school.courses.inject([]) { |r, course| r << create(:cart_item, course: course) }
      create(:purchase_confirmed, user: student, cart_items: cart_items)
      get :show_certificate, course: course, student: student, format: "pdf"
    end

    it "should assign @course" do
    	assigns(:course).should == course
    end
    it "should assign @student" do
    	assigns(:student).should == student
    end
    it "should assign @school" do
    	assigns(:school).should == school
    end
    it "shoul assign @layout_configuration" do
    	assigns(:layout_configuration).should == school.layout_configuration
    end
	end

	# describe "GET students" do
	# 	before(:each) do
	# 		get :students
	# 		school.students = [create(:student)]
	# 	end

	# 	it { assigns(:students).should == user.school.students.to_a }
	# end

	describe "GET team" do
		before(:each) do
			get :team
		end

		it { assigns(:school).should == user.school }
	end

	describe "GET library" do
		before(:each) do
			get :library
		end

		it { assigns(:school).should == user.school }
	end

	describe "GET configurations_general" do
		before(:each) do
			get :configurations_general
		end

		it { assigns(:school).should == user.school }

		it "should set flash school status" do
			flash[:school_status].should == :configurations_general
		end
	end

	describe "GET configurations_notifications" do
		before(:each) do
			get :configurations_notifications
		end

		it { assigns(:school).should == user.school }

		it "should set flash school status" do
			flash[:school_status].should == :configurations_notifications
		end
	end	
end