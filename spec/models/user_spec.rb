#encoding: UTF-8

require 'spec_helper'

describe User do
  describe :validations do
    context :presence do
      it { should validate_presence_of(:password).on(:create) }
      it { should ensure_length_of(:password).is_at_least(6).is_at_most(128) }

      context :purchasing do
        before(:each) { User.current_status = :purchasing }

        [:address, :cpf].each do |attribute|
          it { should validate_presence_of(attribute) }
        end
      end
    end

    context :length do
      it { should ensure_length_of(:first_name).is_at_least(2).is_at_most(100) }

      context :purchasing do
        before(:each) { User.current_status = :purchasing }

        it { should ensure_length_of(:last_name).is_at_least(2).is_at_most(100) }
        it { should ensure_length_of(:phone_number) }
      end
    end

    context :format do
      it "should accept only valid emails" do
        should have_valid(:email).when("john@hotmai..com")
        should have_valid(:email).when("john.boo@hotmail.com")
        should_not have_valid(:email).when("@hotmail")
        should_not have_valid(:email).when("john@")
        should_not have_valid(:email).when("johnoo")
      end
    end

    context :uniqueness do
      it "should validate uniqueness of email on edools" do
        School.current_id = nil
        
        email = "john@email.com"
        user = create(:user, email: email)
        user2 = build(:user, email: email)
        expect {
          user2.save!
        }.to raise_error(ActiveRecord::RecordInvalid, /email já está em uso/)
      end

      it "should validate uniqueness of email when in same school" do
        school = create(:school)
        School.current_id = school.id

        email = "john@email.com"
        user = create(:user, email: email)
        user2 = build(:user, email: email)
        expect {
          user2.save!
        }.to raise_error(ActiveRecord::RecordInvalid, /email já está em uso/)
      end

      it "should not validate uniqueness of email when not in same school" do
        school = create(:school)
        School.current_id = school.id
        
        email = "john@email.com"
        user = create(:user, email: email)
        School.current_id = nil
        user2 = build(:user, email: email)
        expect { user.save! }.not_to raise_error()
      end
    end
  end

  describe :associations do
    it { should have_many(:notifications).dependent(:delete_all) }
    
    it { should have_one(:address) }
    it { should belong_to(:school) }

    [:authentications, :purchases, :courses_invited, :courses_users, 
      :lessons, :lessons_medias, :medias, :course_evaluations].each do |model|
      it { should have_many(model) }
    end
  end 

  describe :methods do
    let(:user) { build(:user) }

    before(:each) do
      User.current_status = nil
    end

    describe '.set_role' do
      it "should set student role if user is created inside a school" do
        school = create(:school)
        School.current_id = school.id
        user = create(:user)
        user.role.should == "student"
      end

      it "should set school_master role is user is created on edools" do
        School.current_id = nil
        user = create(:user)
        user.role.should == "school_admin"
      end
    end

    describe '.save_current_school_id' do
      it "should save current school id" do
        school = create(:school)
        School.current_id = school.id
        user = create(:user)
        user.school_id.should == school.id
      end
    end

    describe '.purchasing?' do
      it "should return true if user current status is purchasing" do
        User.current_status = :purchasing
        user.purchasing?.should be_true
      end
    end

    describe '.editing?' do
      it "should return true if user current status is editing" do
        User.current_status = :editing
        user.editing?.should be_true
      end
    end

    describe '.remove_masks' do
      it 'should remove any non numeric char' do
        user.phone_number = "(98) 7654-3210"
        user.save!
        user.phone_number.should == "9876543210"
      end
    end

    describe '.full_name' do
      it 'returns the first_name plus the last_name' do
        user.first_name = "João"
        user.last_name = "Silva"
        user.full_name.should == "João Silva"
      end
    end

    describe '.admin?' do
      it 'returns true if user has this role' do
        user.role = "admin"
        user.admin?.should be_true
      end

      it 'returns false if user has not this role' do
        user.role = []
        user.admin?.should be_false
      end
    end

    describe '.teacher?' do
      it 'returns true if user has this role' do
        user.role = "teacher"
        user.teacher?.should be_true
      end

      it 'returns false if user has not this role' do
        user.role = []
        user.teacher?.should be_false
      end
    end  

    describe '.school_admin?' do
      it 'returns true if user has this role' do
        user.role = "school_admin"
        user.school_admin?.should be_true
      end

      it 'returns false if user has not this role' do
        user.role = nil
        user.school_admin?.should be_false
      end
    end  

    describe '.student?' do
      it 'returns true if user has this role' do
        user.role = "student"
        user.student?.should be_true
      end

      it 'returns false if user has not this role' do
        user.role = nil
        user.student?.should be_false
      end
    end      

    describe '.apply_omniauth' do
      auth = OmniAuth.config.mock_auth[:facebook]   

      it 'applies facebook data to the user model' do
        user.apply_omniauth(auth)
        user.save!
        authentication = user.authentications.last

        user.image_url.should == auth['info']['image']
        user.email.should == auth['extra']['raw_info']['email']
        user.first_name.should == auth['extra']['raw_info']['first_name']
        user.last_name.should == auth['extra']['raw_info']['last_name']        

        authentication.provider.should == auth['provider']
        authentication.uid.should == auth['uid']
        authentication.token.should == auth['credentials']['token']
      end
    end
  end

end