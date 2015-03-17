#coding: utf-8

require 'spec_helper'

feature 'Courses Show / Publicar / Despublicar' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    login_as @user
  end

  scenario "Administrador da escola publica curso" do
    @course.update_attribute :status, Course::DRAFT
    visit dashboard_course_path(@course)
    click_on "course-publish"

    page.should have_content "Curso publicado com sucesso. Agora ele aparece em sua página."
    page.should have_content "Despublicar"
    current_path.should == dashboard_course_path(@course)
  end

  scenario "Administrador da escola tenta publicar curso incompleto" do
    @course.update_attribute :status, Course::DRAFT
    @course.update_attribute :pitch, ""
    visit dashboard_course_path(@course)
    click_on "course-publish"

    page.should have_content "Sub-título é muito curto (mínimo: 5 caracteres)"
    page.should have_content "Publicar"
    current_path.should == dashboard_course_path(@course)
  end

  scenario "Administrador da escola despublica curso" do
    visit dashboard_course_path(@course)
    click_on "course-unpublish"
    page.should have_content "Curso despublicado com sucesso. Agora ele está invisível ao público."
    page.should have_content "Publicar"
    current_path.should == dashboard_course_path(@course)
  end
end