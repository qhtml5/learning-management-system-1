# encoding: utf-8

require 'spec_helper'

describe MediaWidget do
	has_widgets do |root|
    root << widget(:media)
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
  let(:media) { course.medias.first }
  let(:student) { FactoryGirl.create(:student) }

  before(:each) do
    controller.request.stub subdomain: school.subdomain
    School.current_id = school.id
    MediaWidget.any_instance.stub current_user: student
  end
  
	it "#display - should create an USER_STARTED_MEDIA notification when media is a video" do
    expect { 
      render_widget :media, :display, course: course, media: media
    }.to change(Notification, :count).by(1)
    notification = Notification.last
    notification.sender.should == student
    notification.code.should == Notification::USER_STARTED_MEDIA
    notification.notifiable.should == media
    notification.message == course.title
    notification.personal.should be_true
	end

  it "#display - should create an USER_ENDED_MEDIA notification when media is a slide" do
    media.kind = "Slide"
    media.save!
    expect { 
      render_widget :media, :display, course: course, media: media
    }.to change(Notification, :count).by(1)
    notification = Notification.last
    notification.sender.should == student
    notification.code.should == Notification::USER_ENDED_MEDIA
    notification.notifiable.should == media
    notification.message == course.title
    notification.personal.should be_true
  end  

  it "#display - should create an USER_ENDED_MEDIA notification when media is a text" do
    media.kind = "Text"
    media.text = "Text example of text user media"
    media.save!
    expect { 
      render_widget :media, :display, course: course, media: media
    }.to change(Notification, :count).by(1)
    notification = Notification.last
    notification.sender.should == student
    notification.code.should == Notification::USER_ENDED_MEDIA
    notification.notifiable.should == media
    notification.message == course.title
    notification.personal.should be_true
  end    

end