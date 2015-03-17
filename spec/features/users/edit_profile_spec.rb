#coding: utf-8

require 'spec_helper'

feature 'Editar Dados' do
	background do
		@user = create :student
		login_as @user
		visit edit_profile_user_path
	end

	scenario "Usuário edita seus dados com sucesso" do
		fill_in :user_first_name, with: "Paul"
		fill_in :user_last_name, with: "Lennon"
		fill_in :user_email, with: "paul_lennon@gmail.com"
		fill_in :user_phone_number, with: "2298992600"
		fill_in :user_cpf, with: "138.658.097-07"
		fill_in :user_skype, with: "paul_lennon"
		fill_in :user_biography, with: "Lorem ipsum dolor"

		click_on "Salvar"
		@user.reload

		current_path.should == edit_profile_user_path
		page.should have_content "Dados editados com sucesso"
		@user.first_name.should == "Paul"
		@user.last_name.should == "Lennon"
		@user.email.should == "paul_lennon@gmail.com"
		@user.phone_number.should == "2298992600"
		@user.cpf.to_s.should == "138.658.097-07"
		@user.skype.should == "paul_lennon"
		@user.biography.should == "Lorem ipsum dolor"
	end

	scenario "Usuário edita com dados inválidos" do
		fill_in :user_first_name, with: "Paul"
		fill_in :user_last_name, with: ""
		fill_in :user_email, with: ""
		fill_in :user_phone_number, with: "2298992600"
		fill_in :user_cpf, with: "138.658.097-07"
		fill_in :user_skype, with: "paul_lennon"
		fill_in :user_biography, with: "Lorem ipsum dolor"
		click_on "Salvar"

		[".user_email.error"].each do |field|
			within(field) do
				page.should have_content "não é válido"
			end
		end
	end

	scenario "Usuário edita seus dados preenchendo o endereço" do
		fill_in :user_first_name, with: "Paul"
		fill_in :user_last_name, with: "Lennon"
		fill_in :user_email, with: "paul_lennon@gmail.com"
		fill_in :user_phone_number, with: "2298992600"
		fill_in :user_cpf, with: "138.658.097-07"
		fill_in :user_skype, with: "paul_lennon"
		fill_in :user_biography, with: "Lorem ipsum dolor"

		click_on "Editar endereço"

		fill_in :user_address_attributes_street, with: "Rua Dois"
		fill_in :user_address_attributes_number, with: "200"
		fill_in :user_address_attributes_district, with: "Distrito 2"
		fill_in :user_address_attributes_city, with: "Distrito 2"
		select "RJ", from: :user_address_attributes_state
		fill_in :user_address_attributes_zip_code, with: "24812-128"

		click_on "Salvar"
		@user.reload

		current_path.should == edit_profile_user_path
		page.should have_content "Dados editados com sucesso"
		@user.address.street.should == "Rua Dois"
		@user.address.number.should == "200"
		@user.address.district.should == "Distrito 2"
		@user.address.city.should == "Distrito 2"
		@user.address.state.should == "RJ"

		@user.address.zip_code.should == "24812128"
	end

	scenario "Usuário edita sua senha" do
		fill_in :user_password, with: "123123"
		fill_in :user_password_confirmation, with: "123123"
		fill_in :user_current_password, with: "123456"

		click_on "Salvar"

		current_path.should == edit_profile_user_path
		page.should have_content "Dados editados com sucesso"
	end

	scenario "Usuário tenta editar senha com a senha antiga inválida" do
		fill_in :user_password, with: "123123"
		fill_in :user_password_confirmation, with: "123123"
		fill_in :user_current_password, with: "1234"		

		click_on "Salvar"

		within(".user_current_password.error") do
			page.should have_content "não é válido"
		end
	end

	scenario "Usuário tenta editar senha com a senha em branco" do
		fill_in :user_password, with: "123123"
		fill_in :user_password_confirmation, with: "123123"
		fill_in :user_current_password, with: ""		

		click_on "Salvar"

		within(".user_current_password.error") do
			page.should have_content "não pode ficar em branco"
		end
	end
end
