#coding: utf-8

require 'spec_helper'

feature 'Escola - Alunos' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @school.students = [
      create(:student, first_name: "John", last_name: "Lennon"),
      create(:student, first_name: "Bill", last_name: "Clinton"),
      create(:student, first_name: "Thomas", last_name: "Edison")
    ]
    @school.courses = [FactoryGirl.create(:course)]
    @course = @school.courses.first

    switch_to_subdomain @school.subdomain    
    login_as @user
    visit dashboard_students_path
  end

  scenario "Dono da escola vê lista de alunos" do
    @school.students.each do |student|
      page.should have_content student.full_name
    end
  end

  scenario "Dono da escola busca aluno pelo nome completo", js: true do
    fill_in "user_search", with: "Bill Clinton"
    click_on "Buscar"
    sleep(1)
    page.should have_content "Bill Clinton"
    page.should_not have_content "Thomas Edison"
  end

  scenario "Dono da escola busca aluno pelo primeiro nome", js: true do
    fill_in "user_search", with: "Bill"
    click_on "Buscar"
    sleep(1)
    page.should have_content "Bill Clinton"
    page.should_not have_content "Thomas Edison"
  end  

  scenario "Dono da escola busca aluno pelo último nome", js: true do
    fill_in "user_search", with: "Clinton"
    click_on "Buscar"
    sleep(1)
    page.should have_content "Bill Clinton"
    page.should_not have_content "Thomas Edison"
  end

  scenario "Dono da escola busca com nome em branco", js: true do
    fill_in "user_search", with: ""
    click_on "Buscar"
    sleep(1)
    page.should have_content "Bill Clinton"
    page.should have_content "Thomas Edison"
    page.should have_content "John Lennon"
  end

  scenario "Dono da escola busca por nome não existente", js: true do
    fill_in "user_search", with: "Schumacher"
    click_on "Buscar"
    sleep(1)
    page.should have_content "Não foram encontrados alunos"
  end

  scenario "Dono da escola filtra alunos pelo curso", js: true do
    @course.students_invited = [@school.students.first]
    click_on "filter-#{@course.title}"
    sleep(1)
    page.should have_content "John Lennon"
    page.should_not have_content "Thomas Edison"
  end

end