#coding: utf-8

require 'spec_helper'

feature 'Edita Privacidade' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    login_as @user
    visit edit_certificate_dashboard_course_path(@course)
  end

  scenario "Usuário checa sim" do
    choose "course_certificate_available_true"
    click_on "Salvar"

    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_certificate_dashboard_course_path(@course)
    @course.certificate_available.should be_true
  end

  scenario "Usuário checa não" do
    choose "course_certificate_available_false"
    click_on "Salvar"

    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_certificate_dashboard_course_path(@course)
    @course.certificate_available.should be_false
  end
end