#coding: utf-8

require 'spec_helper'

feature 'Configurações' do
  background do
    visit root_path
  end

  # scenario "Admin da escola se cadastra" do
  # 	fill_in "user_first_name", with: "Carlos"
  # 	fill_in "user_email", with: "carlos@hotmail.com.br"
  # 	fill_in "user_password", with: "123456"
  # 	click_on "create-school-register"

  # 	current_path.should == wizard_basic_info_dashboard_schools_path
  # 	page.should have_content "Cadastro efetuado com sucesso."
  # end

  # scenario "Admin da escola tenta se cadastrar com email já existente" do
  # 	email = "carlos@hotmail.com.br"
  # 	user = create(:school_admin, email: email)
  #   school = user.school.destroy
  #   school.destroy
  #   user.update_attribute :school_id, nil

  # 	fill_in "user_first_name", with: "Carlos"
  # 	fill_in "user_email", with: email
  # 	fill_in "user_password", with: "123456"
  # 	click_on "create-school-register"

  # 	current_path.should == user_registration_path
  # 	page.find_field("user_first_name").value.should == "Carlos"
  # 	page.find_field("user_email").value.should == email

  # 	within(".user_email.error") do
	 #  	page.should have_content "já está em uso"
	 #  end
  # end
end