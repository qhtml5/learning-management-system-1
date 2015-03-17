#coding: utf-8

require 'spec_helper'

feature 'Conteúdo' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course, privacy: Course::RESTRICT, allowed_emails: "carlos@hotmail.com,john@gmail.com")
    switch_to_subdomain @school.subdomain
  end

  scenario "Usuário procede registro com email permitido" do
    visit checkout_restrict_course_path(@course)
    fill_in "registration_first_name", with: "Carlos"
    fill_in "registration_email", with: "carlos@hotmail.com"
    fill_in "registration_password", with: "123456"
    click_on "Criar conta"

    current_path.should == cart_checkouts_path
    # page.should have_content "Carrinho (1)"
    page.should have_content @course.title
  end

  scenario "Usuário procede registro para curso gratuito" do
    @course.update_attribute :price, 0
    visit checkout_restrict_course_path(@course)
    fill_in "registration_first_name", with: "Carlos"
    fill_in "registration_email", with: "carlos@hotmail.com"
    fill_in "registration_password", with: "123456"
    click_on "Criar conta"

    user = User.last
    user.courses_invited.should include @course
    current_path.should == content_course_path(@course)
    page.should have_content @course.title
  end

  scenario "Usuário procede registro sem o email permitido" do
    visit checkout_restrict_course_path(@course)
    fill_in "registration_first_name", with: "Carlos"
    fill_in "registration_email", with: "alberto@gmail.com"
    fill_in "registration_password", with: "123456"
    click_on "Criar conta"

    current_path.should == root_path
    page.should have_content "Este curso é restrito, você não pode incluí-lo no carrinho."
    page.should_not have_content "Carrinho (1)"
  end  

  scenario "Usuário preenche o registro errado" do
    visit checkout_restrict_course_path(@course)
    fill_in "registration_first_name", with: "Carlos"
    click_on "Criar conta"

    page.should have_content "Curso online restrito"
    within(".user_password.error") do
      page.should have_content "não pode ficar em branco"
    end
  end  

  scenario "Usuário procede realizando o login com email permitido" do
    visit checkout_restrict_course_path(@course)
    School.current_id = @school.id
    student = create(:student, email: "john@gmail.com")
    fill_in "user_email_login", with: student.email
    fill_in "user_password_login", with: "123456"
    click_on "login-button"

    current_path.should == cart_checkouts_path
    # page.should have_content "Carrinho (1)"    
  end

  scenario "Usuário procede realizando o login com email permitido - curso gratuito" do
    @course.update_attribute :price, 0
    visit checkout_restrict_course_path(@course)
    School.current_id = @school.id
    student = create(:student, email: "john@gmail.com")
    fill_in "user_email_login", with: student.email
    fill_in "user_password_login", with: "123456"
    click_on "login-button"

    user = User.last
    user.courses_invited.should include @course
    current_path.should == content_course_path(@course)
    page.should have_content @course.title
  end

  scenario "Usuário procede realizando o login sem email permitido" do
    visit checkout_restrict_course_path(@course)
    School.current_id = @school.id
    student = create(:student)
    fill_in "user_email_login", with: student.email
    fill_in "user_password_login", with: "123456"
    click_on "login-button"

    current_path.should == root_path
    page.should have_content "Este curso é restrito, você não pode incluí-lo no carrinho."
    page.should_not have_content "Carrinho (1)"
  end

  scenario "Usuário preenche login errado" do
    visit checkout_restrict_course_path(@course)
    student = create(:student)
    fill_in "user_email_login", with: student.email
    fill_in "user_password_login", with: ""
    click_on "login-button"

    page.should have_content "Curso online restrito"
    page.should have_content "Email ou senha inválidos"
  end

  scenario "Usuário está logado e possui email permitido" do
    student = create(:student, email: "carlos@hotmail.com")
    login_as(student) 
    visit checkout_restrict_course_path(@course)

    current_path.should == cart_checkouts_path
    # page.should have_content "Carrinho (1)"    
  end
  
  scenario "Usuário está logado e não possui email permitido" do
    student = create(:student)
    login_as(student) 
    visit checkout_restrict_course_path(@course)

    current_path.should == root_path
    page.should have_content "Este curso é restrito, você não pode incluí-lo no carrinho."
    page.should_not have_content "Carrinho (1)"
  end
end