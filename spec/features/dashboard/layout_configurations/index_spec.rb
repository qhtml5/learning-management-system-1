#coding: utf-8

require 'spec_helper'

feature 'Configurações de Layout' do
	background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    switch_to_subdomain @school.subdomain
    @course = create(:course)
    login_as @user
  end

  scenario "Usuário atualiza dados do layout" do
    visit dashboard_layout_configurations_path    

    fill_in "layout_configuration_background", with: "FFFFFF"
    fill_in "layout_configuration_menu_bar", with: "000000"
    fill_in "layout_configuration_box_header", with: "333333"
    click_on "Salvar"


    @school.reload
    current_path.should == dashboard_layout_configurations_path
    page.should have_content "Layout atualizado com sucesso"
    @school.layout_configuration.background.should == "FFFFFF"
    @school.layout_configuration.menu_bar.should == "000000"
    @school.layout_configuration.box_header.should == "333333"
  end

  scenario "Usuário atualiza logo" do
    visit dashboard_layout_configurations_path    
        
    attach_file "layout_configuration_site_logo", File.expand_path("#{Rails.root}/spec/support/data/logo-startupbase.png", __FILE__)
    click_on "Salvar"

    current_path.should == dashboard_layout_configurations_path
    page.should have_content "Layout atualizado com sucesso"
    @school.reload
    @school.layout_configuration.site_logo.class.should == Paperclip::Attachment
  end
end