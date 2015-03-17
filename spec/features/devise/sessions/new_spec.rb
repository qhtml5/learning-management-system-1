#coding: utf-8

require 'spec_helper'

feature 'Login' do
  background do
    @user = create(:school_admin)
    @school = @user.school
  end

  context "Dono da escola" do
    scenario "Loga em sua escola" do
      School.current_id = @school.id
      switch_to_subdomain @school.subdomain

      visit new_user_session_path
      fill_in "user_email", with: @user.email
      fill_in "user_password", with: @user.password
      click_on "login-btn"

      current_path.should == dashboard_courses_path
      page.should have_content 'Login efetuado com sucesso!'
    end

    scenario "Loga no www" do
      School.current_id = nil
      switch_to_subdomain "www"

      visit new_user_session_path
      fill_in "user_email", with: @user.email
      fill_in "user_password", with: @user.password
      click_on "login-btn"

      current_path.should == root_path
    end

    scenario "Tenta logar em outra escola" do
      school = create(:school)
      School.current_id = school.id
      switch_to_subdomain school.subdomain

      visit new_user_session_path
      fill_in "user_email", with: @user.email
      fill_in "user_password", with: @user.password
      click_on "login-btn"

      current_path.should == new_user_session_path
      page.should have_content "Email ou senha inválidos"
    end
  end

  context "Aluno" do
    background do
      School.current_id = @school.id
      @student = create(:student)
    end

    scenario "Loga em na sua escola" do
      switch_to_subdomain @school.subdomain
      visit new_user_session_path
      fill_in "user_email", with: @student.email
      fill_in "user_password", with: @student.password
      click_on "login-btn"

      current_path.should == dashboard_courses_path
      page.should have_content 'Login efetuado com sucesso!'
    end

    scenario "Tenta logar em outra escola" do
      school = create(:school)
      School.current_id = school.id
      switch_to_subdomain school.subdomain

      visit new_user_session_path
      fill_in "user_email", with: @student.email
      fill_in "user_password", with: @student.password
      click_on "login-btn"
      current_path.should == new_user_session_path
      page.should have_content "Email ou senha inválidos"
    end

    scenario "Tenta logar no www" do
      School.current_id = nil
      switch_to_subdomain "www"

      visit new_user_session_path
      fill_in "user_email", with: @student.email
      fill_in "user_password", with: @student.password
      click_on "login-btn"
      
      current_path.should == new_user_session_path
      page.should have_content "Email ou senha inválidos"
    end
  end
  
end