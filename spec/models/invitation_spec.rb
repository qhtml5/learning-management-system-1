require 'spec_helper'

describe Invitation do

	describe "self.create_list" do
		let(:school_admin) { create(:school_admin) }
		let(:school) { school_admin.school }
		before(:each) do
			School.current_id = school.id
		end
		let(:course) { create(:course) }
		let(:emails) { ["john@gmail.com","carlos@hotmail.com"] }

		it "should create invitations for all emails" do
			expect {
				Invitation.create_list(emails: emails, course: course)
			}.to change(Invitation, :count).by(2)
			invitation = Invitation.last(2)
			invitation.first.email.should == "john@gmail.com"
			invitation.last.email.should == "carlos@hotmail.com"
		end

		it "should not create invitation if email has already been invited" do
			Invitation.create(email: "john@gmail.com", course: course)
			expect {
				Invitation.create_list(emails: emails, course: course)
			}.to change(Invitation, :count).by(1)
		end

		it "should create notifications for all emails and users" do
			student = create(:student, email: "john@gmail.com")
			expect {
				Invitation.create_list(emails: emails, course: course)
			}.to change(Notification, :count).by(2)
			notification = Notification.last(2)
			notification.first.receiver.should == student
			notification.last.email.should == "carlos@hotmail.com"
		end

		it "should return the list of invitations saved and with errors" do
			emails << "email_invalid"
			invitations = Invitation.create_list(emails: emails, course: course)
	    invitations[:success].length.should == 2
	    invitations[:failure].length.should == 1
		end
	end
end
