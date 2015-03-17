#coding: utf-8

require 'spec_helper'

feature 'Wizard 1o Passo' do
  background do
    visit new_user_registration_path
    fill_in "user_first_name", with: "Carlos"
    fill_in "user_email", with: "carlos@hotmail.com.br"
    fill_in "user_password", with: "123456"
    click_on "Criar conta"
  end

  scenario "Admin da escola informa nome e subdomínio da escola" do
    fill_in "school_name", with: "Endeavor"
    fill_in "school_subdomain", with: "endeavor"
    click_on "Criar escola →"

    # page.should have_content "Escola criada com sucesso! Está iniciando agora seu período de 15 dias de teste gratuito com todas as funcionalidades liberadas."
    current_path.should == dashboard_courses_path
    School.find_by_subdomain("endeavor").plan.should == "trial"
  end

  scenario "Admin da escola informa subdomínio já existente" do
    subdomain = "endeavor"
    create(:school, subdomain: subdomain)

    fill_in "school_name", with: "Endeavor"
    fill_in "school_subdomain", with: subdomain
    click_on "Criar escola →"

    within(".school_subdomain.error") do
      page.should have_content "já está em uso"
    end
  end
end