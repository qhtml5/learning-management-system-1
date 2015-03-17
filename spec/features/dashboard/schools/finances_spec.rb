#coding: utf-8

require 'spec_helper'

feature 'Escola - Financeiro' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    switch_to_subdomain @school.subdomain
    @school.courses = [create(:course)]
    login_as @user
  end

  scenario "Dono da escola vê as informações financeiras da escola" do
    create_list(:purchase_confirmed, 2, cart_items: [create(:cart_item, course: @school.courses.first)], amount_paid: 20900)
    visit finances_dashboard_schools_path
    page.should have_content "R$ 209,00"
  end
end