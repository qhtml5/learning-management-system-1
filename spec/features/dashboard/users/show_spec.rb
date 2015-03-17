#coding: utf-8

require 'spec_helper'

feature 'CRM - Perfil do Aluno' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    switch_to_subdomain @school.subdomain
    School.current_id = @school.id
    @course = create(:course)
    @student = create(:student)
    @student.courses_invited << @course
    
    login_as @user
  end

  scenario "Dono da escola vê perfil do aluno no crm" do
    visit dashboard_student_path(@student)
    page.should have_content @student.full_name
    page.should have_content @student.email
    page.should have_content @student.phone_number
    page.should have_content @student.cpf
    page.should have_content @student.company
    page.should have_content @student.function
  end

  context "Atividades" do
    scenario "Dono da escola vê atividades do aluno" do
      notification1 = create(:notification,
        sender: @student,
        code: Notification::USER_SIGN_IN,
        notifiable: @student,
        personal: true
      )
      notification2 = create(:notification,
        sender: @student,
        code: Notification::USER_VIEW_COURSE_CONTENT,
        notifiable: @course,
        personal: true
      )
      notification1.update_attribute :created_at, Time.now - 2.hours
      visit dashboard_student_path(@student)
      page.should have_content "Acessou o ambiente de conteúdo do curso #{@course.title}"
      page.should have_content "Logou na escola"
    end

    scenario "Dono da escola vê compra liberada do aluno" do
      create(:notification,
        sender: @student,
        code: Notification::PURCHASE_LIBERATED,
        notifiable: create(:purchase),
        personal: true
      )
      visit dashboard_student_path(@student)
      page.should have_content "Teve o acesso liberado"
    end
  end

  context "Mensagens" do
    scenario "Dono da escola envia mensagem para aluno", js: true do
      visit dashboard_student_path(@student)
      click_on "Contatos (0)"
      fill_in "message_to_send_text", with: "Exemplo de mensagem para o aluno"
      click_on "Enviar →"
      sleep(1)
      Message.count.should == 1
      Notification.count.should == 1
      ActionMailer::Base.deliveries.last.subject.should == "#{@school.name} - Novo contato"
      page.should have_content "Mensagem enviada com sucesso"
      page.should have_content "Exemplo de mensagem para o aluno"
      page.should have_content "Contatos (1)"
    end

    scenario "Dono da escola apaga mensagem enviada para o aluno", js: true do
      visit dashboard_student_path(@student)
      click_on "Contatos (0)"
      fill_in "message_to_send_text", with: "Exemplo de mensagem para o aluno"
      click_on "Enviar →"
      sleep(1)
      click_on "apagar"
      sleep(1)
      Message.count.should == 0
      page.should have_content "Mensagem apagada com sucesso"
      page.should have_content "Contatos (0)"
      page.should_not have_content "Exemplo de mensagem para o aluno"
    end
  end

  context "Progresso" do
    scenario "Dono da escola visualiza progresso do aluno no curso" do
      User.any_instance.stub ended_medias: 7, started_medias: 4
      Course.any_instance.stub_chain("medias.available.length").and_return(11)
      visit dashboard_student_path(@student)
      click_on "Progresso (63%)"
      page.should have_content "#{@course.title} (63%)"
      page.should have_content "7 aulas completas"
      page.should have_content "4 aulas iniciadas"
      page.should have_content "11 aulas no total"
    end
  end
end