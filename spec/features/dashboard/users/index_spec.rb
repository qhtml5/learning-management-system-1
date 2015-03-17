#coding: utf-8

require 'spec_helper'

feature 'CRM - Index de Alunos' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    switch_to_subdomain @school.subdomain
    School.current_id = @school.id
    @course = create(:course)
    @students = []
    3.times do
      student = create(:student)
      student.courses_invited << @course
      @students << student
    end
    
    login_as @user
    visit dashboard_students_path
  end

  scenario "Dono da escola envia mensagem para vários alunos", js: true do
    pending "TinyMCE"
    
    check "students_leads_#{@students[0].id}"
    check "students_leads_#{@students[1].id}"
    check "students_leads_#{@students[2].id}"
    click_on "add-message-button"

    fill_in "students_leads_message", with: "Compre meu novíssimo curso!"
    click_on "submit-message"

    sleep(1)
    
    page.should have_content "Mensagem enviada com sucesso para os alunos selecionados."
    deliveries = ActionMailer::Base.deliveries.last(3)
    deliveries.map(&:to).should == @students.map { |s| [s.email] }
    Notification.count.should == 3
    Message.count.should == 3
  end

end