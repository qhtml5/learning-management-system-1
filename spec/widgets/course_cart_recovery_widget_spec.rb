# encoding: utf-8

require 'spec_helper'

describe CourseCartRecoveryWidget do
	has_widgets do |root|
    root << widget(:course_cart_recovery)
  end

  let(:user) { FactoryGirl.create(:school_admin) }
  let(:school) { user.school }
  let(:course) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    school.reload
    school.courses.first
  end
  before(:each) do
    DatabaseCleaner.clean
    controller.request.stub subdomain: school.subdomain
    School.current_id = school.id
    CourseCartRecoveryWidget.any_instance.stub current_user: user
  end
  
	it "#create_lead - success - should create lead and coupon" do
    render_widget :course_cart_recovery, :create_lead, course: course, lead: { email: "john@gmail.com" }
    Lead.count.should == 1
    Coupon.count.should == 1
	end

  it "#create_lead - success - should send email to lead" do
    render_widget :course_cart_recovery, :create_lead, course: course, lead: { email: "john@gmail.com" }
    mail = ActionMailer::Base.deliveries.last
    mail.to.should == ["john@gmail.com"]
    mail.subject.should == "Aqui está o seu cupom! Continue com a compra do curso #{course.title}!"
  end

  it "#create_lead - success - should display coupon sent message" do
    response = render_widget :course_cart_recovery, :create_lead, course: course, lead: { email: "john@gmail.com" }
    response.text.should include "Prossiga a compra através do email que enviamos para john@gmail.com."
  end

  it "#create_lead - failure - should display error message" do
    create(:lead, email: "john@gmail.com", course: course)
    response = render_widget :course_cart_recovery, :create_lead, course: course, lead: { email: "john@gmail.com" }
    response.text.should include "já está em uso"
    response.text.should include "Ganhe 5% de desconto agora!"
  end

end