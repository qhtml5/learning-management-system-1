# encoding: utf-8

require "spec_helper"

describe NotificationMailer do
	before(:each) do
		@school_admin = create(:school_admin)
		@school = @school_admin.school
		School.current_id = @school.id
		@student = create(:student)
		@course = create(:course)
	end

	describe "#user_new_registration" do
		before(:each) do 
      @notification = Notification.new(
        receiver: @school_admin,
        sender: @student,
        code: Notification::USER_NEW_REGISTRATION,
        notifiable: @student
      )
		end

		let(:mail) { NotificationMailer.user_new_registration(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject" do
			mail.subject.should == "Você tem uma nova inscrição na sua escola!"
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
      mail.body.encoded.should =~ /#{@student.full_name}/
    end
	end

	describe "#course_new_certificate_request" do
		before(:each) do
      @notification = Notification.new(
        receiver: @school_admin,
        sender: @student,
        code: Notification::COURSE_NEW_CERTIFICATE_REQUEST,
        notifiable: @course
       )
		end

		let(:mail) { NotificationMailer.course_new_certificate_request(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject" do
			mail.subject.should == "#{@student.full_name} solicitou o certificado do curso #{@course.title}"
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
      mail.body.encoded.should =~ /#{@student.full_name}/
    end
	end

	describe "#course_new_question" do
		before(:each) do
			message = create(:message, user: @student, course: @course)
      @notification = Notification.new(
        receiver: @school_admin,
        sender: @student,
        code: Notification::COURSE_NEW_QUESTION,
        notifiable: message
      )
		end

		let(:mail) { NotificationMailer.course_new_question(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject" do
			mail.subject.should == "#{@student.full_name} enviou uma nova pergunta no curso #{@course.title}"
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
      mail.body.encoded.should =~ /#{@course.title}/
    end
	end

	describe "#course_new_answer" do
		before(:each) do
			message = create(:message, user: @student, course: @course)
      @notification = Notification.new(
        receiver: @student,
        sender: @school_admin,
        code: Notification::COURSE_NEW_ANSWER,
        notifiable: message
       )
		end

		let(:mail) { NotificationMailer.course_new_answer(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@student.email]
		end

		it "should set right subject" do
			mail.subject.should == "#{@school_admin.full_name} respondeu à sua pergunta no curso #{@course.title}"
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.full_name}/
      mail.body.encoded.should =~ /#{@student.first_name}/
    end
	end

	describe "course_add_to_cart" do
		before(:each) do
			message = create(:message, user: @student, course: @course)
      @notification = Notification.new(
        receiver: @school_admin,
        sender: @student,
        code: Notification::COURSE_ADD_TO_CART,
        notifiable: @course
      )
		end

		let(:mail) { NotificationMailer.course_add_to_cart(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject when has sender" do
			mail.subject.should == "#{@student.full_name} adicionou seu curso #{@course.title} ao carrinho."
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
      mail.body.encoded.should =~ /#{@course.title}/
    end
	end

	describe "course_new_evaluation" do
		before(:each) do
      @course_evaluation = create(:course_evaluation, user: @student, course: @course)
      @notification = Notification.new(
        receiver: @school_admin,
        sender: @student,
        code: Notification::COURSE_NEW_EVALUATION,
        notifiable: @course_evaluation
       )
		end

		let(:mail) { NotificationMailer.course_new_evaluation(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject" do
			mail.subject.should == "O aluno #{@student.full_name} avaliou seu curso #{@course.title} com #{@course_evaluation.score} estrelas."
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
      mail.body.encoded.should =~ /#{@student.full_name}/
      mail.body.encoded.should =~ /#{@course.title}/
      mail.body.encoded.should =~ /#{@course_evaluation.score}/
    end		
	end

	describe "purchase_pending" do
		before(:each) do
      @cart_item = create(:cart_item, course: @course)
      @purchase = create(:purchase_pending, cart_items: [@cart_item], user: @student)
      @notification = Notification.new(
        receiver: @school_admin,
        sender: @student,
        code: Notification::PURCHASE_PENDING,
        notifiable: @purchase
       )
		end

		let(:mail) { NotificationMailer.purchase_pending(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject" do
			mail.subject.should == "#{@student.full_name} comprou o curso #{@course.title}. (pagamento pendente)"
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
      mail.body.encoded.should =~ /#{@student.full_name}/
      mail.body.encoded.should =~ /#{@course.title}/
    end				
	end

	describe "purchase_confirmed" do
		before(:each) do
      @cart_item = create(:cart_item, course: @course)
      @purchase = create(:purchase_confirmed, cart_items: [@cart_item], user: @student)
      @notification = Notification.new(
        receiver: @school_admin,
        sender: @student,
        code: Notification::PURCHASE_CONFIRMED,
        notifiable: @purchase
      )
		end

		let(:mail) { NotificationMailer.purchase_confirmed(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject" do
			mail.subject.should == "#{@student.full_name} teve o pagamento confirmado na compra do curso #{@course.title}."
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
      mail.body.encoded.should =~ /#{@student.full_name}/
      mail.body.encoded.should =~ /#{@course.title}/
    end						
	end

	describe "purchase_user_pending" do
		before(:each) do
      @cart_item = create(:cart_item, course: @course)
      @purchase = create(:purchase_pending, cart_items: [@cart_item], user: @student)
      @notification = Notification.new(
        receiver: @student,
        code: Notification::PURCHASE_USER_PENDING,
        notifiable: @purchase
       )
		end

		let(:mail) { NotificationMailer.purchase_user_pending(@notification) }

		it "should send email from school email if present" do
			@school.update_attribute :email, "school_email@example.com"
			mail = NotificationMailer.purchase_user_pending(@notification)
			mail.from.should == [@school.email]
		end

		it "should send email from school admin email if school email is not present" do
			mail.from.should == [@school_admin.email]
		end

		it "should send email to notification receiver email" do
			mail.to.should == [@student.email]
		end

		it "should set right subject" do
			mail.subject.should == "Sua compra do curso #{@course.title} está com o pagamento pendente. Status: #{@purchase.payment_status}"
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@student.first_name}/
      mail.body.encoded.should =~ /#{@course.title}/
    end						
	end

	describe "purchase_user_confirmed" do
		before(:each) do
      @cart_item = create(:cart_item, course: @course)
      @purchase = create(:purchase_confirmed, cart_items: [@cart_item], user: @student)
      @notification = Notification.new(
        receiver: @student,
        code: Notification::PURCHASE_USER_CONFIRMED,
        notifiable: @purchase
       )
		end

		let(:mail) { NotificationMailer.purchase_user_confirmed(@notification) }

		it "should send email from school email if present" do
			@school.update_attribute :email, "school_email@example.com"
			mail = NotificationMailer.purchase_user_confirmed(@notification)
			mail.from.should == [@school.email]
		end

		it "should send email from school admin email if school email is not present" do
			mail.from.should == [@school_admin.email]
		end

		it "should send email to notification receiver email" do
			mail.to.should == [@student.email]
		end

		it "should set right subject" do
			mail.subject.should == "Parabéns! O seu pagamento na compra do curso #{@course.title} foi confirmado."
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@student.first_name}/
      mail.body.encoded.should =~ /#{@course.title}/
    end						
	end

	describe "school_plan_choose" do
		before(:each) do
      @notification = Notification.new(
        receiver: @school_admin,
        code: Notification::SCHOOL_PLAN_CHOOSE,
        notifiable: @school
       )
		end

		let(:mail) { NotificationMailer.school_plan_choose(@notification) }

		it "should send email to notification receiver email" do
			mail.to.should == [@school_admin.email]
		end

		it "should set right subject" do
			mail.subject.should == "Contato para confirmar escolha do plano de pagamento no Edools"
		end

		it 'should show informations on the email body' do
      mail.body.encoded.should =~ /#{@school_admin.first_name}/
    end						
	end
end