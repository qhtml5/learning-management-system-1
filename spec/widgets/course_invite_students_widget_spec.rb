# encoding: utf-8

require 'spec_helper'

describe CourseInviteStudentsWidget do
	has_widgets do |root|
    root << widget(:course_invite_students)
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
  let(:emails) { "jonh@boo.com,carlos@gmail.com,alberto@hotmail.com" }
  let(:wrong_emails) { "jonh@boo.com,carlos@gmail.com),alberto@hotmail.com" }
  before(:each) do
    controller.request.stub subdomain: school.subdomain
    School.current_id = school.id
    CourseInviteStudentsWidget.any_instance.stub current_user: user
  end
  
  it "#invite - success - should create invitations to all emails entered" do
    expect {
      response = render_widget :course_invite_students, :invite, 
                                course: course.id, users: { emails: emails }
    }.to change(Invitation, :count).by(3)
  end

  it "#invite - success - should create invitations to all emails entered when not in school" do
    School.current_id = nil
    expect {
      response = render_widget :course_invite_students, :invite, 
                                course: course.id, users: { emails: emails }
    }.to change(Invitation, :count).by(3)
    Invitation.all.map(&:school).uniq.should == [school]
  end  

  it "#invite - success - should display message of success" do
    response = render_widget :course_invite_students, :invite, 
                              course: course.id, users: { emails: emails }
    response.text.should include "Convites enviados com sucesso para o(s) email(s): jonh@boo.com, carlos@gmail.com, alberto@hotmail.com"
  end

  it "#invite - failure - should display message of failure" do
    response = render_widget :course_invite_students, :invite, 
                              course: course.id, users: { emails: wrong_emails }
    response.text.should include "Convites enviados com sucesso para o(s) email(s): jonh@boo.com, alberto@hotmail.com"
    response.text.should include "Falha ao enviar os convites para o(s) email(s): carlos@gmail.com)"
  end

end