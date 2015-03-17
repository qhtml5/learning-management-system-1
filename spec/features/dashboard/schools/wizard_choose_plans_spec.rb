#coding: utf-8

require 'spec_helper'

feature 'Wizard 2o Passo' do
  background do
    visit new_user_registration_path
    fill_in "user_first_name", with: "Carlos"
    fill_in "user_email", with: "carlos@hotmail.com.br"
    fill_in "user_password", with: "123456"
    click_on "create-school-register"
    fill_in "school_name", with: "Endeavor"
    fill_in "school_subdomain", with: "endeavor"
    click_on "Prosseguir >>"
  end

  # scenario "Admin da escola escolhe o plano para sua escola" do
  #   choose "school_plan_middle"
  #   click_on "Criar escola!"

  #   current_path.should == dashboard_courses_path
  #   page.should have_content "Parabéns! Sua escola foi criada com sucesso!"
  # end

end