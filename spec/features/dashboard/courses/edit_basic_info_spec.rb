#coding: utf-8

require 'spec_helper'

feature 'Edição de Informações Básicas' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    @course_category = create(:course_category)
    switch_to_subdomain @school.subdomain
    login_as @user
    visit edit_basic_info_dashboard_course_path(@course)
  end

  scenario "Usuário edita informações básicas do curso" do
    fill_in "course_title", with: "Outro bom curso"
    fill_in "course_pitch", with: "Como fazer um bom curso"
    select @course_category.name, from: "course_course_category_id"
    click_on "Salvar"

    @course.reload
    current_path.should == edit_basic_info_dashboard_course_path(@course)    
    page.should have_content "Curso atualizado com sucesso"
    @course.title.should == "Outro bom curso"
    @course.slug.should == "outro-bom-curso"
    @course.pitch.should == "Como fazer um bom curso"
    @course.course_category.should == @course_category
  end

  scenario "Usuário deixa título do curso inválido" do
    fill_in "course_title", with: "Curs"
    click_on "Salvar"

    within(".course_title.error") do
      page.should have_content "é muito curto (mínimo: 5 caracteres)"
    end
  end
end