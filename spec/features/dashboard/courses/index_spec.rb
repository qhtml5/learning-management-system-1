#coding: utf-8

require 'spec_helper'

feature 'Index de Cursos' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @school.courses = create_list(:course, 3, school: @school)
    switch_to_subdomain(@school.subdomain)
    School.current_id = @school.id
  end

  context "Administrador da Escola" do
    background do
      login_as @user
      visit dashboard_courses_path
    end
    
    scenario "Visualiza todos os cursos da escola" do
      @user.courses.length.should == 3
      @user.courses.each do |course|
        within("#course-#{course.slug}") do
          page.should have_content course.title
        end
      end
    end

    scenario "Cria um novo curso" do      
      click_on "new-course"
      fill_in "course_title", with: "Melhor curso do mundo"
      click_on "submit-course"

      page.should have_content "Curso criado com sucesso"
      page.should have_content "Melhor curso do mundo"
      current_path.should == dashboard_course_path(Course.last)
    end

    scenario "Tenta criar curso com nome em branco" do      
      click_on "new-course"
      fill_in "course_title", with: ""
      click_on "submit-course"

      page.should have_content "Título é muito curto (mínimo: 5 caracteres)"
      current_path.should == dashboard_courses_path
    end
  end

  context "Professor" do
    background do
      @teacher = create(:teacher, school: @school)
      @school.courses.each { |course| course.update_attribute :teachers, [@teacher] }
      login_as @teacher
      
      visit dashboard_courses_path
    end

    scenario "Visualiza os cursos em que é professor" do
      @teacher.courses.length.should == 3
      @teacher.courses.each do |course|
        within("#course-#{course.slug}") do
          page.should have_content course.title
        end
      end
    end
  end

  context "Aluno" do
    background do
      @student = create(:student, school: @school)
      @student.reload
      login_as @student
    end
    
    context "Compras" do
      scenario "Visualiza curso confirmado sem data de validade" do
        course = @school.courses.first
        course.update_attribute :available_time, 0
        cart_item = create(:cart_item, course: course)
        purchase = create(:purchase_confirmed, user: @student, cart_items: [cart_item])

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Disponível indeterminadamente"
          page.html.should include content_course_path(course)
        end
      end

      scenario "Visualiza curso liberado" do
        course = @school.courses.first
        course.update_attribute :available_time, 0
        cart_item = create(:cart_item, course: course)
        purchase = create(:purchase, user: @student, cart_items: [cart_item], payment_status: "Liberado")

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Disponível indeterminadamente"
          page.html.should include content_course_path(course)
        end
      end      

      scenario "Visualiza curso confirmado com data de validade" do
        course = @school.courses.first
        course.update_attribute :available_time, 5
        cart_item = create(:cart_item, course: course, confirmed_at: Time.now)
        purchase = create(:purchase_confirmed, user: @student, cart_items: [cart_item])

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Disponível até #{I18n.l(cart_item.expires_at, format: :medium)}"
          page.html.should include content_course_path(course)
        end
      end

      scenario "Visualiza curso com data de validade porém comprou quando não tinha" do
        course = @school.courses.first
        cart_item = create(:cart_item, course: course)
        purchase = create(:purchase_confirmed, user: @student, cart_items: [cart_item])
        course.update_attribute :available_time, 5

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Disponível indeterminadamente"
          page.html.should include content_course_path(course)
        end
      end    

      scenario "Visualiza curso pendente" do
        course = @school.courses.first
        cart_item = create(:cart_item, course: course)
        purchase = create(:purchase, user: @student, cart_items: [cart_item])

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Pagamento #{purchase.payment_status}"
          page.html.should include purchases_user_path
        end
      end

      scenario "Visualiza curso expirado" do
        course = @school.courses.first
        course.update_attribute :available_time, 5
        cart_item = create(:cart_item, course: course)
        purchase = create(:purchase_confirmed, user: @student, cart_items: [cart_item])
        cart_item.update_attribute :confirmed_at, Time.now - 6.days

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Período terminado em #{I18n.l(cart_item.expires_at, format: :medium)}"
          page.html.should include course_path(course)
        end
      end
    end

    context "Convites" do
      scenario "Visualiza curso sem data de validade" do
        course = @school.courses.first
        course.update_attribute :available_time, 0
        @student.update_attribute :courses_invited, [course]

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Disponível indeterminadamente"
          page.html.should include content_course_path(course)
        end
      end

      scenario "Visualiza curso com data de validade" do
        course = @school.courses.first
        course.update_attribute :available_time, 5
        @student.update_attribute :courses_invited, [course]
        @student.reload
        course_user = @student.courses_users.first

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Disponível até #{I18n.l(course_user.expires_at, format: :medium)}"
          page.html.should include content_course_path(course)
        end
      end

      scenario "Visualiza curso com data de validade porém comprou quando não tinha" do
        course = @school.courses.first
        course.update_attribute :available_time, 0
        @student.update_attribute :courses_invited, [course]
        @student.reload
        course_user = @student.courses_users.first
        course.update_attribute :available_time, 5

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Disponível até #{I18n.l(course_user.expires_at, format: :medium)}"
          page.html.should include content_course_path(course)
        end
      end    

      scenario "Visualiza curso expirado" do
        course = @school.courses.first
        course.update_attribute :available_time, 5
        @student.update_attribute :courses_invited, [course]
        @student.reload
        course_user = @student.courses_users.first
        course_user.update_attribute :created_at, Time.now - 6.days

        visit dashboard_courses_path

        within("#course-#{course.slug}") do
          page.should have_content course.title
          page.should have_content "Período terminado em #{I18n.l(course_user.expires_at, format: :medium)}"
          page.html.should include course_path(course)
        end
      end
    end    

  end
end