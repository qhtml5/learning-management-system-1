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
    visit edit_privacy_dashboard_course_path(@course)
  end

  scenario "Usuário checa privado" do
    choose "course_privacy_private"
    click_on "Salvar"

    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_privacy_dashboard_course_path(@course)
    @course.privacy.should == Course::PRIVATE
  end

  scenario "Usuário checa publico" do
    choose "course_privacy_public"
    click_on "Salvar"

    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_privacy_dashboard_course_path(@course)
    @course.privacy.should == Course::PUBLIC
  end

  scenario "Usuário checa restrito" do
    choose "course_privacy_restrict"
    fill_in "course_allowed_emails", with: "john@gmail.com,carlos@hotmail.com"
    click_on "Salvar"

    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_privacy_dashboard_course_path(@course)
    @course.reload
    @course.privacy.should == Course::RESTRICT
    @course.allowed_emails.should == "john@gmail.com,carlos@hotmail.com"
  end  
end