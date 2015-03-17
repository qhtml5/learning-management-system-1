#coding: utf-8

require 'spec_helper'

feature 'Checkout Social' do
	background do
    @school = create(:school)
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
		visit add_to_cart_course_path(@course)
		click_on "checkout"
	end

	# context "Facebook" do
	# 	background do
	# 		@auth = OmniAuth.config.mock_auth[:facebook]
	# 	end

	# 	scenario "Aluno se conecta com o facebook" do
	# 		click_on "facebook-login"
	# 		@user = Authentication.last.user

	# 		current_path.should == register_checkouts_path
	# 		page.find_field("user_email").value.should == @user.email
	# 		page.find_field("user_first_name").value.should == @user.first_name
	# 		page.find_field("user_last_name").value.should == @user.last_name
	# 		page.should have_selector("img[src$='#{@auth[:info][:image]}']")
	# 	end

	# 	scenario "Aluno tenta se conectar com o facebook com credenciais inválidas" do
	# 		OmniAuth.config.mock_auth.stub(:[]).with(:facebook).and_return :invalid_credentials
	# 		click_on "facebook-login"

	# 		current_path.should == root_path
	# 		page.should have_content "Ocorreu algum erro ao realizar login."
	# 	end
	# end

	context "Cadastro" do
		scenario "Aluno se conecta fazendo cadastro" do
			fill_in "registration_first_name", with: "Paul"
			fill_in "registration_email", with: "paul@gmail.com"
			fill_in "registration_password", with: "123456"
			click_on "Criar conta"

			@user = User.last

			current_path.should == register_checkouts_path
			page.should have_content "Cadastro efetuado com sucesso."
			page.find_field("user_email").value.should == @user.email
			page.find_field("user_first_name").value.should == @user.first_name
		end

		scenario "Aluno preenche o cadastro errado" do
			fill_in "registration_first_name", with: "Paul"
			fill_in "registration_email", with: "paul@gmail.com"
			fill_in "registration_password", with: ""
			click_on "Criar conta"

			within(".user_password.error") do
				page.should have_content "não pode ficar em branco"
			end
		end
	end

	context "Login" do
		scenario "Aluno se conecta fazendo login" do
			School.current_id = @school.id
			@user = create(:student)
			fill_in "user_email", with: @user.email
			fill_in "user_password", with: @user.password
			click_on "login-button"

			current_path.should == register_checkouts_path
			page.should have_content "Login efetuado com sucesso!"
			page.find_field("user_email").value.should == @user.email
			page.find_field("user_first_name").value.should == @user.first_name
		end

		scenario "Aluno preenche login errado" do
			fill_in "user_email", with: "paul"
			fill_in "user_password", with: ""
			click_on "login-button"

			current_path.should == social_checkouts_path
			page.should have_content "Email ou senha inválidos"
		end
	end
end
