#coding: utf-8

require 'spec_helper'

feature 'Edição de Informações Detalhadas' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    login_as @user
    visit edit_detailed_info_dashboard_course_path(@course)
  end

  scenario "Usuário edita informações detalhadas do curso" do
    fill_in "course_content_and_goals", with: "Conteúdos e objetivos"
    fill_in "course_description", with: "Descrição do curso"
    click_on "Salvar"

    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_detailed_info_dashboard_course_path(@course)
    @course.content_and_goals.should == "Conteúdos e objetivos"
    @course.description.should == "Descrição do curso"
  end

  scenario "Usuário tenta editar informações detalhadas do curso com dados inválidos" do
    fill_in "course_content_and_goals", with: "Conte"
    fill_in "course_description", with: "Descr"
    click_on "Salvar"

    ["content_and_goals", "description"].each do |field|
      within(".course_#{field}.error") do
        page.should have_content "é muito curto"
      end
    end
  end
end