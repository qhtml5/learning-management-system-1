#coding: utf-8

require 'spec_helper'

feature 'Escola - Biblioteca' do
	background do
		@user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    @course.medias.first.update_attribute(:wistia_hashed_id, "abc123")
    @school.update_attribute(:wistia_public_project_id, "abc123")
    switch_to_subdomain @school.subdomain
    login_as @user
	end
	
	scenario "Dono da escola visualiza mídia em uso", js: true do
    project = Wistia::Project.new
    project.stub(medias: [Wistia::Media.new(name: "Projeto 1", type: "Video", hashed_id: "abc123")])
    Wistia::Project.stub(:find).and_return(project)
    visit library_dashboard_schools_path
		page.should have_content "Projeto 1"
		page.should have_content "Video"
		page.should have_content "Em uso"
	end

	scenario "Dono da escola visualiza mídia não utilizada", js: true do
		project = Wistia::Project.new
    project.stub(medias: [Wistia::Media.new(name: "Projeto 1", type: "Video", hashed_id: "xyz456")])
    Wistia::Project.stub(:find).and_return(project)
    visit library_dashboard_schools_path

		page.should have_content "Projeto 1"
		page.should have_content "Video"
		page.should have_content "Não utilizado"
	end
	
	scenario "Dono da escola deleta uma mídia que não está em uso", js: true do
		project = Wistia::Project.new
    project.stub(medias: [Wistia::Media.new(name: "Projeto 1", type: "Video", hashed_id: "xyz456")])
    Wistia::Project.stub(:find).and_return(project)
    visit library_dashboard_schools_path

    media = Wistia::Media.new
    Wistia::Media.stub(find: media)
    media.should_receive(:destroy).exactly(1).times.and_return(true)
		first(:link, "Deletar").click
		page.should have_content 'Mídia apagada com sucesso'
	end
	
end