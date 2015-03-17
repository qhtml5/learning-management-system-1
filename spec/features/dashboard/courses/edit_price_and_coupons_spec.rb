#coding: utf-8

require 'spec_helper'

feature 'Edição de Preço e Cupons' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    login_as @user
    visit edit_price_and_coupon_dashboard_course_path(@course)
  end

  scenario "Usuário edita preço" do
    fill_in "course_price", with: 3001
    click_on "Salvar"

    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_price_and_coupon_dashboard_course_path(@course)
    @course.price.should == 3001
  end

  scenario "Usuário edita preço com 0" do
    @school.update_attribute :can_create_free_course, true
    fill_in "course_price", with: 0
    click_on "Salvar"

    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_price_and_coupon_dashboard_course_path(@course)
    @course.price.should == 0
  end

  scenario "Usuário tenta editar preço com valor inválido" do
    fill_in "course_price", with: 2999
    click_on "Salvar"
    
    page.should have_content "deve ser maior do que #{Course::MINIMUM_PRICE.em_real}"
  end

  scenario "Usuário cria cupom" do
    tomorrow = Date.tomorrow

    click_on "new-coupon"
    fill_in "coupon_name", with: "Cupom promocional"
    fill_in "coupon_discount", with: "10"
    select tomorrow.day, from: "coupon_expiration_date_3i"
    select "Dezembro", from: "coupon_expiration_date_2i"
    select tomorrow.year, from: "coupon_expiration_date_1i"
    select "23", from: "coupon_expiration_date_4i"
    select "59", from: "coupon_expiration_date_5i"
    fill_in "coupon_quantity", with: "50"
    click_on "Criar Cupom"

    @coupon = Coupon.last
    page.should have_content "Cupom criado com sucesso"
    current_path.should == edit_price_and_coupon_dashboard_course_path(@course)
    page.should have_content @coupon.name
    page.should have_content @coupon.discount
    page.should have_content I18n.l(@coupon.expiration_date, format: :long)
    page.should have_content @coupon.quantity
    page.should have_content @coupon.quantity_left
  end

  scenario "Usuário cria cupom inválido" do
    yesterday = Date.yesterday

    click_on "new-coupon"
    fill_in "coupon_name", with: ""
    fill_in "coupon_discount", with: "101"
    select yesterday.day, from: "coupon_expiration_date_3i"
    select "Janeiro", from: "coupon_expiration_date_2i"
    select yesterday.year, from: "coupon_expiration_date_1i"
    select "23", from: "coupon_expiration_date_4i"
    select "59", from: "coupon_expiration_date_5i"
    fill_in "coupon_quantity", with: ""
    click_on "Criar Cupom"

    ["name", "quantity"].each do |field|
      within(".coupon_#{field}.error") do
        page.should have_content "não pode ficar em branco"
      end
    end

    within(".coupon_discount.error") do
      page.should have_content "deve ser menor ou igual a 100"
    end

    within(".coupon_expiration_date.error") do
      page.should have_content "deve ser em algum data no futuro"
    end
  end

  scenario "Usuário remove um cupom" do
    @coupon = create(:coupon, course: @course)
    visit edit_price_and_coupon_dashboard_course_path(@course)
    
    expect {
      click_on "delete-coupon-#{@coupon.id}"
      }.to change(@course.coupons, :count).by(-1)

    page.should have_content "Cupom removido com sucesso"
  end
end