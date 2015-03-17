# encoding: utf-8

require 'spec_helper'

describe CourseEvaluationWidget do
	has_widgets do |root|
    root << widget(:course_evaluation)
  end

  let(:user) { FactoryGirl.create(:school_admin) }
  let(:school) { user.school }
  before(:each) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    controller.request.stub subdomain: school.subdomain
    CourseEvaluationWidget.any_instance.stub current_user: user
  end
  let(:course) { user.school.courses.first }
  
	it "#process_course_evaluation - success - should send notification to school admins and course teachers" do
    course.teachers = [create(:teacher)]
    course.save!
    Notification.should_receive(:create_list).with do |*args|
      notification = args.pop
      notification[:sender].should == user
      notification[:receivers].should == school.admins + course.teachers
      notification[:code].should == Notification::COURSE_NEW_EVALUATION
      notification[:notifiable].score.should == 5
      true
    end
   	trigger :submit, :course_evaluation, score: "5",
                                         course_evaluation: { course_id: course.id }
	end

end