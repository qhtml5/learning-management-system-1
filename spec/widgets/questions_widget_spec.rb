# encoding: utf-8

require 'spec_helper'

describe QuestionsWidget do
	has_widgets do |root|
    root << widget(:questions)
  end

  let(:user) { FactoryGirl.create(:school_admin) }
  let(:school) { user.school }
  before(:each) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    controller.request.stub subdomain: school.subdomain
    QuestionsWidget.any_instance.stub current_user: user
  end
  let(:course) { user.school.courses.first }
  
	it "#submit_message - success - should send notification to school team" do
    school.teachers = [create(:teacher)]
    school.save!
    Notification.should_receive(:create_list).with do |*args|
      notification = args.pop
      notification[:sender].should == user
      notification[:receivers].should == school.team
      notification[:code].should == Notification::COURSE_NEW_QUESTION
      notification[:notifiable].text.should == "But how can I do this?"
      true
    end
   	trigger :submit_message, :questions, course: course.id, 
   																			 message: { text: "But how can I do this?" }
	end

	it "#submit_answer - success - should send notification to user who asked the question" do
		school.teachers = [create(:teacher)]
    school.save!
    message = create(:message, course: course)
    Notification.stub create_list: true
    Notification.should_receive(:create).with do |*args|
      notification = args.pop
      notification[:sender].should == user
      notification[:receiver].should == message.user
      notification[:code].should == Notification::COURSE_NEW_ANSWER
      notification[:notifiable].text.should == "This is an answer"
      true
    end
   	trigger :submit_answer, :questions, course: course.id, 
   																			question: message.id,
   																			message: { text: "This is an answer" }
	end

	it "#submit_answer - success - should send notification to school team" do
		school.teachers = [create(:teacher)]
    school.save!
    message = create(:message, course: course)
    Notification.stub create: true
    Notification.should_receive(:create_list).with do |*args|
      notification = args.pop
      notification[:sender].should == user
      notification[:receivers].should == school.team
      notification[:code].should == Notification::COURSE_NEW_QUESTION
      notification[:notifiable].text.should == "This is an answer"
      true
    end
   	trigger :submit_answer, :questions, course: course.id, 
   																			question: message.id,
   																			message: { text: "This is an answer" }
	end

end