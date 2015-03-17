#coding: utf-8

require 'spec_helper'

feature 'Escola - Configurações - Gerais' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    switch_to_subdomain @school.subdomain
    login_as @user
    visit configurations_moip_dashboard_schools_path
  end

  scenario "Usuário atualiza login no moip da escola" do
    fill_in "school_moip_login", with: "john_locke"
    click_on "Salvar"

    current_path.should == configurations_moip_dashboard_schools_path
    page.should have_content "Conta MoIP atualizada com sucesso."
    page.find_field("school_moip_login").value.should == "john_locke"
  end

  scenario "Usuário tenta atualizar com o login moip inválido" do
    fill_in "school_moip_login", with: "22"
    click_on "Salvar"

    page.find_field("school_moip_login").value.should == "22"
    page.should have_content "é muito curto (mínimo: 6 caracteres)"
  end

  scenario "Usuário tenta atualizar com uma carteira inválida"
end