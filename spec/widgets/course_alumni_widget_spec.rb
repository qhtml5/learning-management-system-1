# encoding: utf-8

require 'spec_helper'

describe CourseAlumniWidget do
	has_widgets do |root|
    root << widget(:course_alumni)
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
    controller.request.stub subdomain: school.subdomain
    School.current_id = school.id
    cart_item1 = create(:cart_item, course: course)
    cart_item2 = create(:cart_item, course: course)
    create(:purchase_confirmed, user: create(:student), cart_items: [cart_item1])
    create(:purchase_confirmed, user: create(:student), cart_items: [cart_item2])
    CourseAlumniWidget.any_instance.stub current_user: user
  end
  
	it "#display - should set right title and render display if course has any students" do
    response  = render_widget :course_alumni, :display, course: course
    response.should have_text "2 alunos já fizeram esse curso"
    response.all(:img, ".img-circle").length.should == 2
	end

  it "#display - should render nothing if students are empty" do
    course.stub(active_users: [], expired_users: [])
    response  = render_widget :course_alumni, :display, course: course
    response.text.should be_empty
  end

end