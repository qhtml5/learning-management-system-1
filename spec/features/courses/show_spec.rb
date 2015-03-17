#coding: utf-8

require 'spec_helper'

feature 'Conteúdo' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    switch_to_subdomain @school.subdomain
    @course = create(:course)
  end

  scenario "Usuário vê dados básicos do curso" do
    visit course_path(@course)
    page.should have_content @course.title
    page.should have_content @course.pitch
    page.should have_content @course.description
    page.should have_content @course.price.em_real
    within("#content_and_goals") do
      page.should have_content @course.content_and_goals
    end
    within("#who_should_attend") do
      page.should have_content @course.who_should_attend
    end
    within("#course_school") do
      page.should have_content @school.name
    end
    page.should have_content "Perguntas Frequentes"
  end

  scenario "Usuário vai para a pagina de checkout de um curso gratuito" do
    @school.can_create_free_course = true
    @school.save!
    @course.reload
    @course.price = 0
    @course.save!
    
    visit course_path(@course)
    click_on "course-buy-#{@course.slug}"
    current_path.should == checkout_free_course_path(@course) 
  end

  scenario "Usuário logado se matricula em curso gratuito" do
    @school.can_create_free_course = true
    @school.save!
    @course.reload
    @course.price = 0
    @course.save!

    student = create(:student)
    login_as(student)
    visit course_path(@course)
    click_on "course-buy-#{@course.slug}"
    current_path.should == content_course_path(@course) 
  end

  scenario "Usuário vai para a pagina de checkout de um curso restrito" do
    @course.update_attribute :privacy, Course::RESTRICT

    visit course_path(@course)
    page.should have_content "Matricule-se"
    click_on "course-buy-#{@course.slug}"
    current_path.should == checkout_restrict_course_path(@course)
  end  

  context "Recuperação de carrinho" do
    scenario "Usuário adiciona email para receber cupom de desconto", js: true do
      @school.cart_recovery = true
      @school.save!

      visit course_path(@course)
      click_on "course-buy-#{@course.slug}"

      fill_in "lead_email", with: "john@malkovic.com"

      click_button "submit-lead"

      page.should have_content "Cupom enviado!"
    end
  end
  
end