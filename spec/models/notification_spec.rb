#coding: utf-8

require 'spec_helper'

describe Notification do
  
  describe :validations do
    context :presence do
    	[:receiver, :code, :notifiable].each do |model|
	      it { should validate_presence_of(model) }
	    end
    end
  end

  describe :associations do
  	[:sender, :receiver, :notifiable].each do |model|
			it { should belong_to(model) }
		end
  end	

  describe '.check_if_its_not_repeated' do
    it "should not create repeat notifications if its a media notification" do
      school = create(:school)
      School.current_id = school.id
      student = create(:student)
      course = create(:course)
      media = course.medias.first
      2.times { 
        Notification.create(
          sender: student,
          code: Notification::USER_ENDED_MEDIA,
          notifiable: media,
          message: course.title,
          personal: true
        )
      }
      Notification.count.should == 1
    end

    it "should not create repeated notifications if its time sensitive notification" do
      student = create(:student)
      2.times { 
        Notification.create(
          sender: student,
          code: Notification::USER_SIGN_IN,
          notifiable: student,
          personal: true
        )
      }
      Notification.count.should == 1
    end

    it "should create repeated notifications if its time sensitive notification and the time has passed" do
      student = create(:student)
      Notification.create(
        sender: student,
        code: Notification::USER_SIGN_IN,
        notifiable: student,
        personal: true
      )
      Time.stub now: Time.now + 3.hours
      Notification.create(
        sender: student,
        code: Notification::USER_SIGN_IN,
        notifiable: student,
        personal: true
      )
      Notification.count.should == 2
    end

    it "should create repeated notifications when its not special notifications" do
      student = create(:student)
    end
  end

  describe 'self.create_list' do
    it "should create a list of notifications" do
      user = create(:school_admin)
      student = create(:student)
      school = user.school
      school.teachers = [create(:teacher)]
      school.save!
      Notification.should_receive(:create).exactly(2).times
      Notification.create_list(
        sender: student, 
        receivers: school.team, 
        code: Notification::COURSE_ADD_TO_CART, 
        notifiable: user
        )
    end
  end

  describe '.send_mail' do    
  	it "should send email corresponding to code (new user registration)" do
      user = create(:school_admin)
      notification = create(:notification, code: Notification::USER_NEW_REGISTRATION, receiver: user)
      email = ActionMailer::Base.deliveries.first
      email.from.should == ["contato@edools.com"]
      email.to.should == [user.email]
      email.subject.should == "Você tem uma nova inscrição na sua escola!"
  	end

    it "should send email corresponding to code (course new question)" do
      user = create(:school_admin)
      school = user.school
      School.current_id = school.id
      course = create(:course)
      school.update_attribute :courses, [course]
      message = create(:message, course: course)
      expect {
        notification = create(:notification, 
          code: Notification::COURSE_NEW_QUESTION, 
          sender: message.user,
          receiver: user,
          notifiable: message
        )
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      email = ActionMailer::Base.deliveries.first
      email.from.should == ["contato@edools.com"]
      email.to.should == [user.email]
      email.subject.should == "#{user.full_name} enviou uma nova pergunta no curso #{course.title}"
    end

    it "should not send email if the school is configured not to" do
      user = create(:school_admin)
      school = user.school
      school.build_notification_configuration
      school.notification_configuration.course_new_question = false
      school.save!
      School.current_id = school.id
      course = create(:course)
      school.update_attribute :courses, [course]
      message = create(:message, course: course)
      expect {
        create(:notification, 
          code: Notification::COURSE_NEW_QUESTION, 
          sender: message.user,
          receiver: user,
          notifiable: message
        )
      }.not_to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
