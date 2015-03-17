#coding: utf-8

require 'spec_helper'

feature 'Escola - Edição de informações' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    switch_to_subdomain @school.subdomain
    login_as @user
    visit edit_basic_info_dashboard_schools_path
  end

  scenario "Usuário atualiza as informações da escola" do
    fill_in "school_name", with: "Endeavor"
    fill_in "school_about_us", with: "A endeavor é a maior escola do Brasil"
    fill_in "school_site", with: "www.endeavor.com.br"
    fill_in "school_facebook", with: "endeavorbrasil"
    fill_in "school_twitter", with: "endeavorbrasil"
    click_on "Salvar"

    current_path.should == edit_basic_info_dashboard_schools_path
    page.should have_content "Informações atualizadas com sucesso."
    page.find_field("school_name").value.should == "Endeavor"
    page.find_field("school_about_us").value.should == "A endeavor é a maior escola do Brasil"
  end

  scenario "Usuário tenta atualiza com dados inválidos" do
    fill_in "school_name", with: ""
    click_on "Salvar"

    within(".school_name.error") do
      page.should have_content "não pode ficar em branco"
    end
  end
end