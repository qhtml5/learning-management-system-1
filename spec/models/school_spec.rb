require 'spec_helper'

describe School do
  
  describe :associations do
    [:users, :admins, :teachers, :students, :courses].each do |model|
      it { should have_many(model) }
    end
    it { should have_one(:layout_configuration) }
  end
  
  describe :validations do
    context :presence do
      [:name, :subdomain].each do |model|
        it { should validate_presence_of(model) }
      end
    end

    context :length do
      it { should allow_value("").for(:moip_login) }
      it { should ensure_length_of(:subdomain).is_at_least(3).is_at_most(30) }
      it { should ensure_length_of(:moip_login).is_at_least(6).is_at_most(30) }
    end

    context :format do
      it "should not accept special characters on subdomain" do
        should have_valid(:subdomain).when("john_foo2")
        should have_valid(:subdomain).when("john.foo")
        should_not have_valid(:subdomain).when("john.f$oo")
        # should_not have_valid(:subdomain).when("john..foo")
        # should_not have_valid(:subdomain).when("john__foo")
      end
    end
  end

  describe :methods do
    context 'self.send_two_days_to_end_trial_mail' do
      it "should send email to schools that are on trial and have two days left" do
        schools = create_list(:school, 2, plan: School::TRIAL)
        schools.each do |school|
          school.update_attribute :created_at, Time.now - 14.days
        end
        School.send_two_days_to_end_trial_mail
        ActionMailer::Base.deliveries.map(&:to).should == [[schools[0].owner.email],[schools[1].owner.email]]
      end

      it "should send not email to schools that are not on trial and have two days left" do
        schools = create_list(:school, 2, plan: School::CUSTOM)
        schools.each do |school|
          school.update_attribute :created_at, Time.now - 14.days
        end
        School.send_two_days_to_end_trial_mail
        ActionMailer::Base.deliveries.should == []
      end      

      it "should send not email to schools that are on trial and have other than two days left" do
        schools = create_list(:school, 2, plan: School::TRIAL)
        schools.each do |school|
          school.update_attribute :created_at, Time.now - 15.days
        end
        School.send_two_days_to_end_trial_mail
        ActionMailer::Base.deliveries.should == []
      end      
    end

    context 'self.send_one_day_to_end_trial_mail' do
      it "should send email to schools that are on trial and have two days left" do
        schools = create_list(:school, 2, plan: School::TRIAL)
        schools.each do |school|
          school.update_attribute :created_at, Time.now - 16.days
        end
        School.send_end_trial_mail
        ActionMailer::Base.deliveries.map(&:to).should == [[schools[0].owner.email],[schools[1].owner.email]]
      end

      it "should send not email to schools that are not on trial and have two days left" do
        schools = create_list(:school, 2, plan: School::CUSTOM)
        schools.each do |school|
          school.update_attribute :created_at, Time.now - 16.days
        end
        School.send_end_trial_mail
        ActionMailer::Base.deliveries.should == []
      end      

      it "should send not email to schools that are on trial and have other than two days left" do
        schools = create_list(:school, 2, plan: School::TRIAL)
        schools.each do |school|
          school.update_attribute :created_at, Time.now - 17.days
        end
        School.send_end_trial_mail
        ActionMailer::Base.deliveries.should == []
      end      
    end    
  end  
end
