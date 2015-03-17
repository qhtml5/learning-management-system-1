#coding: utf-8

require 'spec_helper'

feature 'Escola - Avaliações' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    @course.course_evaluations = [create(:course_evaluation, course: @course)]
    @course.save!
    switch_to_subdomain @school.subdomain
    login_as @user
    visit course_evaluations_dashboard_schools_path
  end

  scenario "Administrador da escola visualiza avaliações dos cursos" do
    course_evaluation = @course.course_evaluations.first
    page.should have_content @course.title
    page.should have_content course_evaluation.user.full_name
    page.should have_content course_evaluation.comment
  end
end