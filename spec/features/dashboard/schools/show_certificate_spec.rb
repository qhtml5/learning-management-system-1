#coding: utf-8

require 'spec_helper'

feature 'Escola - Mostrar certificado' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    switch_to_subdomain @school.subdomain
    @course = create(:course)
    @student = create(:student)
    @cart_items = @school.courses.inject([]) { |r, course| r << create(:cart_item, course: course) }
    create(:purchase_confirmed, user: @student, cart_items: @cart_items)
    login_as @user
    visit dashboard_students_path
  end

  # scenario "Dono da escola gera certificado para aluno" do
  #   click_on "show-certificate-#{@course.id}-#{@student.id}"
  #   current_path.should == show_certificate_dashboard_schools_path(@course, @student)
  # end
end