#coding: utf-8

require 'spec_helper'

feature 'Conteúdo' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @school.update_attribute :can_create_free_course, true
    @course = create(:course, school: @school, price: 0)
    switch_to_subdomain @school.subdomain
    @invitation = create(:invitation, course: @course)
    visit checkout_invitation_course_path(@course, user_email: @invitation.email)
  end

  scenario "Usuário procede realizando o registro" do
    fill_in "registration_first_name", with: "Carlos"
    fill_in "registration_password", with: "123456"
    click_on "Criar conta"

    current_path.should == content_course_path(@course)
    page.should have_content "Parabéns! Você foi cadastrado e já pode consumir o conteúdo deste curso!"
  end

  scenario "Usuário preenche o registro errado" do
    fill_in "registration_first_name", with: "Carlos"
    click_on "Criar conta"

    within(".user_password.error") do
      page.should have_content "não pode ficar em branco"
    end
  end  

  scenario "Usuário procede realizando o login" do
    School.current_id = @school.id
    student = create(:student, email: @invitation.email)
    fill_in "user_password_login", with: "123456"
    click_on "login-button"

    current_path.should == content_course_path(@course)
    page.should have_content "Parabéns! Você está logado e já pode consumir o conteúdo do curso."
  end

  scenario "Usuário preenche login errado" do
    fill_in "user_password_login", with: ""
    click_on "login-button"

    page.should have_content "Email ou senha inválidos"
  end
  
end