#coding: utf-8

require 'spec_helper'

feature 'Checkout gratuito' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @school.update_attribute :can_create_free_course, true
    @course = create(:course, school: @school, price: 0)
    switch_to_subdomain @school.subdomain
    visit checkout_free_course_path(@course)
  end

  scenario "Usuário procede realizando o registro" do
    fill_in "registration_first_name", with: "Carlos"
    fill_in "registration_email", with: "carlos@hotmail.com.br"
    fill_in "registration_password", with: "123456"
    fill_in "registration_company", with: "Facebook"
    fill_in "registration_function", with: "Garbageman"
    click_on "Criar conta"

    current_path.should == content_course_path(@course)
    page.should have_content "Parabéns! Você foi cadastrado e já pode consumir o conteúdo deste curso!"
  end

  scenario "Usuário deixa campos em branco no registro" do
    fill_in "registration_first_name", with: "Carlos"
    fill_in "registration_email", with: "carlos@hotmail.com.br"
    fill_in "registration_password", with: "123456"
    fill_in "registration_company", with: ""
    fill_in "registration_function", with: ""
    click_on "Criar conta"

    within(".user_company.error") do
      page.should have_content "não pode ficar em branco"
    end

    within(".user_function.error") do
      page.should have_content "não pode ficar em branco"
    end
  end

  scenario "Usuário procede realizando o login" do
    School.current_id = @school.id
    student = create(:student)
    fill_in "user_email_login", with: student.email
    fill_in "user_password_login", with: "123456"
    click_on "login-button"

    current_path.should == content_course_path(@course)
    page.should have_content "Parabéns! Você está logado e já pode consumir o conteúdo do curso."
  end
  
end