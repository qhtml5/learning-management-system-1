# encoding: utf-8
require 'spec_helper'

describe NotificationsHelper do
  before(:each) do
    @school_admin = create(:school_admin, first_name: "Johnny", last_name: "Cash")
    @school = @school_admin.school
    School.current_id = @school.id
    @student = create(:student, first_name: "Carlos", last_name: "Alberto")
    @course = create(:course, school: @school, title: "Como Fazer um Curso")
  end

  describe '#notification_text' do
    context "when Notification::COURSE_NEW_QUESTION" do
      it "should return correct text for that notification" do
        message = create(:message, user: @student, course: @course)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::COURSE_NEW_QUESTION,
          notifiable: message)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> fez uma nova pergunta no curso <strong>Como Fazer um Curso</strong>".html_safe
      end
    end

    context "when Notification::COURSE_NEW_ANSWER" do
      it "should return correct text for that notification" do
        message = create(:message, user: @student, course: @course)
        notification = Notification.new(
          receiver: @student,
          sender: @school_admin,
          code: Notification::COURSE_NEW_ANSWER,
          notifiable: message)
        helper.notification_text(notification).should == "<strong>Johnny Cash</strong> respondeu sua pergunta no curso <strong>Como Fazer um Curso</strong>".html_safe
      end
    end

    context "when Notification::COURSE_NEW_EVALUATION" do
      it "should return correct text for that notification" do
        course_evaluation = create(:course_evaluation, user: @student, course: @course)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::COURSE_NEW_EVALUATION,
          notifiable: course_evaluation)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> avaliou em <strong>5</strong> estrelas o curso <strong>Como Fazer um Curso</strong>".html_safe
      end
    end

    context "when Notification::PURCHASE_PENDING" do
      it "should return correct text for that notification" do
        cart_item = create(:cart_item, course: @course)
        purchase = create(:purchase_pending, cart_items: [cart_item], user: @student)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::PURCHASE_PENDING,
          notifiable: purchase)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> comprou o curso <strong>Como Fazer um Curso</strong>. (pagamento pendente)".html_safe
      end

      it "should return correct text for more than one course" do
        course2 = create(:course, school: @school, title: "Como Cortar Seu Cabelo")
        cart_items = []
        cart_items << create(:cart_item, course: @course)
        cart_items << create(:cart_item, course: course2)
        purchase = create(:purchase_pending, cart_items: cart_items, user: @student)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::PURCHASE_PENDING,
          notifiable: purchase)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> comprou os cursos <strong>Como Fazer um Curso, Como Cortar Seu Cabelo</strong>. (pagamento pendente)".html_safe
      end      
    end

    context "when Notification::PURCHASE_CONFIRMED" do
      it "should return correct text for one course" do
        cart_item = create(:cart_item, course: @course)
        purchase = create(:purchase_confirmed, cart_items: [cart_item], user: @student)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::PURCHASE_CONFIRMED,
          notifiable: purchase)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> teve o pagamento confirmado na compra do curso <strong>Como Fazer um Curso</strong>.".html_safe
      end

      it "should return correct text for more than one course" do
        course2 = create(:course, school: @school, title: "Como Cortar Seu Cabelo")
        cart_items = []
        cart_items << create(:cart_item, course: @course)
        cart_items << create(:cart_item, course: course2)
        purchase = create(:purchase_confirmed, cart_items: cart_items, user: @student)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::PURCHASE_CONFIRMED,
          notifiable: purchase)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> teve o pagamento confirmado na compra dos cursos <strong>Como Fazer um Curso, Como Cortar Seu Cabelo</strong>.".html_safe
      end
    end

    context "when Notification::PURCHASE_USER_PENDING" do
      it "should return correct text for one course" do
        cart_item = create(:cart_item, course: @course)
        purchase = create(:purchase_pending, cart_items: [cart_item], user: @student)
        notification = Notification.new(
          receiver: @student,
          code: Notification::PURCHASE_USER_PENDING,
          notifiable: purchase)
        helper.notification_text(notification).should == "Sua compra do curso <strong>Como Fazer um Curso</strong> está com o pagamento pendente. Status: Em Analise".html_safe
      end

      it "should return correct text for more than one course" do
        course2 = create(:course, school: @school, title: "Como Cortar Seu Cabelo")
        cart_items = []
        cart_items << create(:cart_item, course: @course)
        cart_items << create(:cart_item, course: course2)
        purchase = create(:purchase_pending, cart_items: cart_items)
        notification = Notification.new(
          receiver: @student,
          code: Notification::PURCHASE_USER_PENDING,
          notifiable: purchase)
        helper.notification_text(notification).should == "Sua compra dos cursos <strong>Como Fazer um Curso, Como Cortar Seu Cabelo</strong> está com o pagamento pendente. Status: Em Analise".html_safe
      end      
    end

    context "when Notification::PURCHASE_USER_CONFIRMED" do
      it "should return correct text for one course" do
        cart_item = create(:cart_item, course: @course)
        purchase = create(:purchase_confirmed, cart_items: [cart_item], user: @student)
        notification = Notification.new(
          receiver: @student,
          code: Notification::PURCHASE_USER_CONFIRMED,
          notifiable: purchase)
        helper.notification_text(notification).should == "O seu pagamento na compra do curso <strong>Como Fazer um Curso</strong> foi confirmado.".html_safe
      end

      it "should return correct text for more than one course" do
        course2 = create(:course, school: @school, title: "Como Cortar Seu Cabelo")
        cart_items = []
        cart_items << create(:cart_item, course: @course)
        cart_items << create(:cart_item, course: course2)
        purchase = create(:purchase_confirmed, cart_items: cart_items)
        notification = Notification.new(
          receiver: @student,
          code: Notification::PURCHASE_USER_CONFIRMED,
          notifiable: purchase)
        helper.notification_text(notification).should == "O seu pagamento na compra dos cursos <strong>Como Fazer um Curso, Como Cortar Seu Cabelo</strong> foi confirmado.".html_safe
      end      
    end

    context "when Notification::COURSE_ADD_TO_CART" do
      it "should return correct text for when sender is present" do
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::COURSE_ADD_TO_CART,
          notifiable: @course)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> adicionou o curso <strong>Como Fazer um Curso</strong> ao carrinho.".html_safe
      end
    end

    context "when Notification::USER_NEW_REGISTRATION" do
      it "should return correct text" do
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::USER_NEW_REGISTRATION,
          notifiable: @student)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> entrou na escola.".html_safe
      end
    end

    context "when Notification::USER_NEW_COURSE_INVITATION" do
      it "should return correct text" do
        notification = Notification.new(
          sender: @student,
          code: Notification::USER_NEW_COURSE_INVITATION,
          notifiable: @course)
        helper.notification_text(notification).should == "Você foi convidado para assistir ao curso <strong>Como Fazer um Curso</strong>".html_safe
      end
    end

    context "when Notification::COURSE_NEW_CERTIFICATE_REQUEST" do
      it "should return correct text" do
        notification = Notification.new(
            receiver: @school_admin,
            sender: @student,
            code: Notification::COURSE_NEW_CERTIFICATE_REQUEST,
            notifiable: @course)
        helper.notification_text(notification).should == "<strong>Carlos Alberto</strong> solicitou o certificado do curso <strong>Como Fazer um Curso</strong>".html_safe
      end
    end

    context "when Notification::SCHOOL_PLAN_CHOOSE" do
      it "should return correct text" do
        notification = Notification.new(
            receiver: @school_admin,
            code: Notification::SCHOOL_PLAN_CHOOSE,
            notifiable: @school)
        helper.notification_text(notification).should == "Parabéns, <strong>Johnny</strong>! Você criou a sua escola!".html_safe
      end
    end
  end

  describe '#notification_path' do
    context "when Notification::COURSE_NEW_QUESTION" do
      it "should return correct path" do
        message = create(:message, user: @student, course: @course)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::COURSE_NEW_QUESTION,
          notifiable: message)
        helper.notification_path(notification).should == content_course_path(@course, notification: { click: true, id: notification.id })
      end
    end  

    context "when Notification::COURSE_NEW_ANSWER" do
      it "should return correct path" do
        message = create(:message, user: @student, course: @course)
        notification = Notification.new(
          receiver: @student,
          sender: @school_admin,
          code: Notification::COURSE_NEW_ANSWER,
          notifiable: message)
        helper.notification_path(notification).should == content_course_path(@course, notification: { click: true, id: notification.id })
      end
    end

    context "when Notification::COURSE_NEW_EVALUATION" do
      it "should return correct path" do
        course_evaluation = create(:course_evaluation, user: @student, course: @course)
        notification = Notification.new(
          receiver: @school_admin,
          sender: @student,
          code: Notification::COURSE_NEW_EVALUATION,
          notifiable: course_evaluation)
        helper.notification_path(notification).should == course_evaluations_dashboard_schools_path(notification.notifiable.course, notification: { click: true, id: notification.id })
      end
    end

    context "when Notification::PURCHASE_PENDING" do
      it "should return correct path" do
        notification = Notification.new(code: Notification::PURCHASE_PENDING)
        helper.notification_path(notification).should == dashboard_students_path(notification: { click: true, id: notification.id })
      end
    end

    context "when Notification::PURCHASE_CONFIRMED" do
      it "should return correct path" do
        notification = Notification.new(code: Notification::PURCHASE_CONFIRMED)
        helper.notification_path(notification).should == dashboard_students_path(notification: { click: true, id: notification.id })
      end
    end

    context "when Notification::PURCHASE_USER_PENDING" do
      it "should return correct path" do
        notification = Notification.new(code: Notification::PURCHASE_USER_PENDING)
        helper.notification_path(notification).should == dashboard_courses_path
      end
    end    

    context "when Notification::PURCHASE_USER_CONFIRMED" do
      it "should return correct path" do
        notification = Notification.new(code: Notification::PURCHASE_USER_CONFIRMED)
        helper.notification_path(notification).should == dashboard_courses_path
      end
    end

    context "when Notification::COURSE_NEW_CERTIFICATE_REQUEST" do
      it "should return correct path" do
        notification = Notification.new(code: Notification::COURSE_NEW_CERTIFICATE_REQUEST)
        helper.notification_path(notification).should == dashboard_students_path(notification: { click: true, id: notification.id })
      end
    end

    context "when Notification::SCHOOL_PLAN_CHOOSE" do
      it "should return correct path" do
        notification = Notification.new(code: Notification::SCHOOL_PLAN_CHOOSE)
        helper.notification_path(notification).should == edit_basic_info_dashboard_schools_path
      end
    end

    context "when Notification::USER_NEW_COURSE_INVITATION" do
      it "should return correct path" do
        invitation = create(:invitation, course: @course)
        notification = Notification.new(
          email: invitation.email,
          code: Notification::USER_NEW_COURSE_INVITATION,
          notifiable: invitation
        )
        helper.notification_path(notification).should == checkout_invitation_course_path(notification.notifiable.course, user_email: notification.notifiable.email, notification: { click: true, id: notification.id })
      end
    end    

    context "else" do
      it "should return correct path" do
        notification = Notification.new
        helper.notification_path(notification).should == notifications_user_path(notification: { click: true, id: notification.id })
      end
    end
  end

end
