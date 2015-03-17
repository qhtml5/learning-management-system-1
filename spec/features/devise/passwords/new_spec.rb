#coding: utf-8

require 'spec_helper'

feature 'Recuperação de Senha' do
  background do
    @user = create(:school_admin)
    @school = @user.school
  end

  context "Dono da escola" do
    scenario "Pede em sua escola" do
      School.current_id = @school.id
      switch_to_subdomain @school.subdomain

      visit new_user_password_path
      fill_in "user_email", with: @user.email
      click_on "send-instructions"

      current_path.should == new_user_session_path
      page.should have_content 'Dentro de minutos, você receberá um e-mail com instruções para a troca da sua senha.'
    end

    scenario "Pede no www" do
      School.current_id = nil
      switch_to_subdomain "www"

      visit new_user_password_path
      fill_in "user_email", with: @user.email
      click_on "send-instructions"

      current_path.should == new_user_session_path
      page.should have_content 'Dentro de minutos, você receberá um e-mail com instruções para a troca da sua senha.'
    end

    scenario "Tenta pedir em outra escola" do
      school = create(:school)
      School.current_id = school.id
      switch_to_subdomain school.subdomain

      visit new_user_password_path
      fill_in "user_email", with: @user.email
      click_on "send-instructions"

      page.should have_content "Email não encontrado"
    end
  end

  context "Aluno" do
    background do
      School.current_id = @school.id
      @student = create(:student)
    end

    scenario "Pede em na sua escola" do
      switch_to_subdomain @school.subdomain
      visit new_user_password_path
      fill_in "user_email", with: @student.email
      click_on "send-instructions"

      current_path.should == new_user_session_path
      page.should have_content 'Dentro de minutos, você receberá um e-mail com instruções para a troca da sua senha.'
    end

    scenario "Tenta pedir em outra escola" do
      school = create(:school)
      School.current_id = school.id
      switch_to_subdomain school.subdomain

      visit new_user_password_path
      fill_in "user_email", with: @student.email
      click_on "send-instructions"
      page.should have_content "Email não encontrado"
    end

    scenario "Tenta pedir no www" do
      School.current_id = nil
      switch_to_subdomain "www"

      visit new_user_password_path
      fill_in "user_email", with: @student.email
      click_on "send-instructions"
      
      page.should have_content "Email não encontrado"
    end
  end
  
end