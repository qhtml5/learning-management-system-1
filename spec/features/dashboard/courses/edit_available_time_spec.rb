#coding: utf-8

require 'spec_helper'

feature 'Edição de Tempo Disponível' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    login_as @user
  end

  scenario "Usuário checa tempo indeterminado" do
    @course.update_attribute :available_time, 5
    visit edit_available_time_dashboard_course_path(@course)
    choose "availability_ilimited"
    click_on "Salvar"
    page.should have_content "Curso atualizado com sucesso!"
    current_path.should == edit_available_time_dashboard_course_path(@course)
    @course.reload
    @course.available_time.should == 0
  end

  scenario "Usuário checa tempo limitado e escolhe a quantidade de dias" do
    @course.update_attribute :available_time, 0
    visit edit_available_time_dashboard_course_path(@course)
    choose "availability_limited"
    fill_in "course_available_time", with: "5"
    click_on "Salvar"
    page.should have_content "Curso atualizado com sucesso!"
    current_path.should == edit_available_time_dashboard_course_path(@course)
    @course.reload
    @course.available_time.should == 5
  end

end