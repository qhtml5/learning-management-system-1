# encoding: utf-8

require 'spec_helper'

describe CoursesController do
  let(:user) { FactoryGirl.create(:school_admin) }
  let(:school) { user.school }
  before(:each) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    controller.request.stub subdomain: school.subdomain
  end
  let(:course) { user.school.courses.first }

  describe "GET content" do
    it "should create an USER_VIEW_COURSE_CONTENT notification" do
      sign_in(user)
      expect {
        get :content, id: course.id
      }.to change(Notification, :count).by(1)
      notification = Notification.last
      notification.sender.should == user
      notification.code.should == Notification::USER_VIEW_COURSE_CONTENT
      notification.notifiable.should == course
      notification.personal.should be_true
    end
  end

  describe "GET add_to_cart" do
    it "should send notifications to school team if not current_user" do
      school.teachers = [create(:teacher)]
      school.save!
      Notification.should_not_receive(:create_list)
      get :add_to_cart, id: course.id
    end

    it "should send notifications to school team if current_user" do
      student = create(:student)
      sign_in(student)
      school.teachers = [create(:teacher)]
      school.save!
      Notification.should_receive(:create_list).with do |*args|
        notification = args.pop
        notification[:sender].should == student
        notification[:receivers].should == school.team
        notification[:code].should == Notification::COURSE_ADD_TO_CART
        notification[:notifiable].should == course
        true
      end
      get :add_to_cart, id: course.id
    end

    context "with coupon parameter" do
      let(:coupon) { create(:coupon, course: course) }

      it "should assign @coupon" do
        get :add_to_cart, id: course.id, coupon: coupon.name
        assigns(:coupon).should == coupon
      end

      it "should save cart item with coupon" do
        get :add_to_cart, id: course.id, coupon: coupon.name
        cart_item = CartItem.last
        cart_item.coupon.should == coupon
      end

      it "should set flash alert if coupon is invalid" do
        coupon.update_attribute :expiration_date, Date.today - 1.day
        get :add_to_cart, id: course.id, coupon: coupon.name
        flash[:alert].should == I18n.t("messages.course.add_to_cart.invalid_coupon")
      end
    end

    context "restrict course and user email not allowed" do
      let(:student) { create(:student) }
      before(:each) do
        course.update_attribute :privacy, Course::RESTRICT
        course.update_attribute :allowed_emails, "john@gmail.com,carlos@hotmail.com"
        sign_in(student)
      end

      it "should set alert" do
        get :add_to_cart, id: course.id
        flash[:alert].should == I18n.t("messages.course.add_to_cart.restrict")
      end

      it "should redirect to root page" do
        get :add_to_cart, id: course.id
        response.should redirect_to root_path(subdomain: school.subdomain)
      end
    end
  end

  describe "GET show" do
    it "should assign @course" do
      get :show, id: course.id
      assigns(:course).should == course
    end

    it "should assign @school" do
      get :show, id: course.id
      assigns(:school).should == course.school
    end

    it "should assign @title" do
      get :show, id: course.id
      assigns(:title).should == course.title
    end    
  end

  describe "GET remove_from_cart" do
    context "success" do
      let(:cart_item) { create(:cart_item, course: course) }
      let(:cart) { cart_item.cart }
      before(:each) { controller.stub current_cart: cart }

      it "should destroy cart item" do
        expect { 
          get :remove_from_cart, id: course.id
        }.to change(CartItem, :count).by(-1)
        cart.cart_items.should be_empty
      end

      it "should redirect to cart page" do
        get :remove_from_cart, id: course.id
        response.should redirect_to cart_checkouts_path
      end

      it "should not destroy if cart item doesn't exist" do
        CartItem.stub(find_by_cart_id_and_course_id: nil)
        CartItem.any_instance.should_not_receive(:destroy)
        get :remove_from_cart, id: course.id
      end
    end

    context "failure" do
      it "should redirect to root" do
        get :remove_from_cart, id: course.id
      end

      it "should set flash message" do
        get :remove_from_cart, id: course.id
      end
    end
  end

  describe "POST request_certificate" do
    let(:student) { create(:student, school: school) }
    let(:teacher) { create(:teacher, school: school) }

    before(:each) do
      cart_items = school.courses.inject([]) { |r, course| r << create(:cart_item, course: course) }
      create(:purchase_confirmed, user: student, cart_items: cart_items)
      course.teachers = [teacher]
      course.save!
      controller.stub current_user: student
    end

    context "success" do
      it "should send notifications to school team and course teachers" do
        Notification.should_receive(:create_list).with do |*args|
          notification = args.pop
          notification[:sender].should == student
          notification[:receivers].should == [user] + [teacher]
          notification[:notifiable].should == course
          notification[:code].should == Notification::COURSE_NEW_CERTIFICATE_REQUEST
          true
        end
        post :request_certificate, id: course.id
      end

      it "should set flash notice" do
        post :request_certificate, id: course.id
        flash[:notice].should == "Solicitação de certificado enviada com sucesso"
      end
    end

    context "failure" do
      it "should set flash alert" do
        Notification.should_receive(:create_list).and_raise
        post :request_certificate, id: course.id
        flash[:alert].should == "Ocorreu um erro ao solicitar seu certificado"
      end
    end

    it "should redirect to course content page" do
      post :request_certificate, id: course.id
      response.should redirect_to content_course_path(course)
    end
  end

  describe "GET checkout_free" do
    before(:each) do
      school.update_attribute :can_create_free_course, true
      course.update_attribute :price, 0
    end

    it "should assign @course" do
      get :checkout_free, id: course.id
      assigns(:course).should == course
    end

    it "should assign @school" do
      get :checkout_free, id: course.id
      assigns(:school).should == course.school
    end

    it "should assign @user" do
      get :checkout_free, id: course.id
      assigns(:user).should be_an_instance_of(User)
    end

    context "user is signed in" do
      let(:student) { create(:student) }
      before(:each) do
        sign_in(student)
      end

      it "should associate course with user" do
        get :checkout_free, id: course.slug
        student.reload
        student.courses_invited.should include course
      end

      it "should redirect to content course page" do
        get :checkout_free, id: course.slug
        response.should redirect_to content_course_path
      end
    end

    it "should redirect to root page if course is not free" do
      course.update_attribute :price, 3000
      get :checkout_free, id: course.id
      response.should redirect_to root_path(subdomain: school.subdomain)
    end  
  end

  describe "GET checkout_invitation" do
    let(:user_email) { "john@gmail.com" }
    before(:each) do
      create(:invitation, course: course, email: user_email)
    end

    it "should assign @course" do
      get :checkout_invitation, id: course.id, user_email: user_email
      assigns(:course).should == course
    end

    it "should assign @school" do
      get :checkout_invitation, id: course.id, user_email: user_email
      assigns(:school).should == course.school
    end

    it "should assign @user" do
      get :checkout_invitation, id: course.id, user_email: user_email
      assigns(:user).should be_an_instance_of(User)
    end

    it "should assign @invitation" do
      get :checkout_invitation, id: course.id, user_email: user_email
      assigns(:invitation).should be_an_instance_of(Invitation)
    end    

    it "should redirect to root page if can't find invitation" do
      get :checkout_invitation, id: course.id, user_email: "carlos@hotmail.com"
      response.should redirect_to root_path(subdomain: school.subdomain)
    end

    context "user signed in and email is same as invitation" do
      let(:student) { create(:student, email: user_email) }
      before(:each) { sign_in(student) }

      it "should associate course with user" do
        get :checkout_invitation, id: course.id, user_email: user_email
        student.reload
        student.courses_invited.should include course
      end

      it "should destroy the invitation" do
        expect {
          get :checkout_invitation, id: course.id, user_email: user_email
        }.to change(Invitation, :count).by(-1)
      end

      it "should redirect to content course page" do
        get :checkout_invitation, id: course.id, user_email: user_email
        response.should redirect_to content_course_path(course)
      end
    end

    context "user signed in and email is different" do
      let(:student) { create(:student, email: user_email) }
      before(:each) do 
        create(:invitation, course: course, email: "carlos@gmail.com")
        sign_in(student) 
      end

      it "should redirect to request referer if present" do
        controller.request.stub(:referer).and_return(course_path(course))
        get :checkout_invitation, id: course.id, user_email: "carlos@gmail.com"
        response.should redirect_to course_path(course)
      end

      it "should redirect to root if referer not present" do
        get :checkout_invitation, id: course.id, user_email: "carlos@gmail.com"
        response.should redirect_to root_path(subdomain: school.subdomain)
      end
    end
  end

end

