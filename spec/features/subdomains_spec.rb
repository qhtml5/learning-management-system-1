#coding: utf-8

require 'spec_helper'

feature 'Subdomínios' do
	background do
		@user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @school.courses = create_list(:course, 2)
    login_as @user
	end

	context "Em um subdomínio" do
		background do
			switch_to_subdomain @school.subdomain
		end

		scenario "Página inical deve ser a página de cursos do usuário" do
			visit root_path
			current_url.should == "http://#{@school.subdomain}.lvh.me/"
			@user.courses.each do |course|
				page.should have_content course.title
			end
		end

		scenario "Ao visitar outra página o subdomínio deve ser mantido" do
			visit root_path
			click_on "Meu Perfil"
			current_url.should == "http://#{@school.subdomain}.lvh.me/perfil/editar"
		end
	end

	context "No domínio principal" do
		scenario "Página inicial deve ser o index (com www)" do
			switch_to_subdomain "www"
			visit root_path
			current_url.should == "http://www.lvh.me/"
		end

		scenario "Página inicial deve ser o index (sem www)" do
			switch_to_subdomain ""
			visit root_path
			current_url.should == "http://www.lvh.me/"
		end
	end
end