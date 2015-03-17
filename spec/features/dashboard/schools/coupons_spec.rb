#coding: utf-8

require 'spec_helper'

feature 'Escola - Conversões - Cupons' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    switch_to_subdomain @school.subdomain
    @school.courses = [create(:course)]
    @course = @school.courses.first
    login_as @user
  end

  scenario "Dono da escola vê as conversões por cupom" do
    coupon1 = create(:coupon, course: @course, name: "LOCKE")
    coupon2 = create(:coupon, course: @course, name: "JOHN")
    3.times do
      create(:purchase_confirmed, cart_items: [create(:cart_item, course: @school.courses.first, coupon: coupon1)])
    end
    2.times do
      create(:purchase_confirmed, cart_items: [create(:cart_item, course: @school.courses.first, coupon: coupon2)])
    end
    
    visit coupons_dashboard_schools_path
    
    page.should have_content "LOCKE"
    page.should have_content "3"
    page.should have_content "JOHN"
    page.should have_content "2"
  end
end