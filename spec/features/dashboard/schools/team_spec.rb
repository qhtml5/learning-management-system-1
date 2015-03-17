#coding: utf-8

require 'spec_helper'

feature 'Escola - Equipe' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    switch_to_subdomain @school.subdomain
    School.current_id = @school.id
    @teacher = create(:teacher)
    @teacher = create(:teacher)
    
    login_as @user
    visit team_dashboard_schools_path
  end

  scenario "Dono da escola deve ver toda sua equipe listada" do
  	@school.team.length.should == 3
  	@school.team.each do |user|
	  	page.should have_content user.full_name
	  	page.should have_content user.email
	  end
  end
end