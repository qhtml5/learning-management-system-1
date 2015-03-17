#coding: utf-8

require 'spec_helper'

feature 'Curso - Edição de Links e Downloads' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    login_as @user
    visit edit_links_downloads_dashboard_course_path(@course)
  end

  scenario "Usuário edita links do curso" do
    fill_in "course_downloads", with: "Downloads do curso"
    click_on "Salvar"

    current_path.should == edit_links_downloads_dashboard_course_path(@course)    
    page.should have_content "Curso atualizado com sucesso"
  end

end