#coding: utf-8

require 'spec_helper'

feature 'Conteúdo' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    @lesson = @course.lessons.last
    switch_to_subdomain @school.subdomain
    login_as @user
    visit dashboard_course_lessons_path(@course)
	end

  context "Módulo" do
    scenario "Admin da escola cria um módulo", js: true do
      click_on "new-module"
      fill_in "lesson_title", with: "Como fazer um curso"
      click_on I18n.t('btn.module.create')

      current_path.should == dashboard_course_lessons_path(@course)
      page.should have_content 'Módulo criado com sucesso'
      page.should have_content "Como fazer um curso"
    end

    scenario "Admin da escola tenta adicionar um módulo com nome inválido", js: true do
      click_on "new-module"
      fill_in "lesson_title", with: "Com"
      click_on I18n.t('btn.module.create')

      current_path.should == dashboard_course_lessons_path(@course)
      page.should have_content "Título é muito curto (mínimo: 5 caracteres)"
    end

    scenario "Admin da escola edita o nome da lição" do
      pending 
    end

    scenario "Admin da escola remove um módulo", js: true do
      click_on "new-module"
      fill_in "lesson_title", with: "Como fazer um curso"
      click_on I18n.t('btn.module.create')

      sleep(1)

      lesson = Lesson.find_by_title("Como fazer um curso")
      click_on "delete-module-#{lesson.id}"

      current_path.should == dashboard_course_lessons_path(@course)
      page.should have_content "Módulo removido com sucesso"
      page.should_not have_content "Como fazer um curso"
    end
  end

  context "Aula" do
    background do
      click_on "new-module"
      fill_in "lesson_title", with: "Como fazer um curso"
      click_on I18n.t('btn.module.create')
    end

    scenario "Admin da escola adiciona uma aula à um módulo", js: true do
      click_on "new-media-#{@lesson.id}"
      fill_in "media_title", with: "Introdução ao investimento anjo"
      click_on I18n.t('btn.lesson.create')

      current_path.should == dashboard_course_lessons_path(@course)
      page.should have_content "Aula criada com sucesso."
      page.should have_content "Introdução ao investimento anjo"
    end

    scenario "Admin da escola adicionar um vídeo à aula"

    scenario "Admin da escola edita uma aula"

    scenario "Admin da escola visualizar mídia da aula"

    scenario "Admin da escola adiciona uma atividade à aula" #, js: true do
      # pending "Faltar descobrir como preencher um campo com tinymce"

      # click_on "new-media-#{@lesson.id}"
      # fill_in "media_title", with: "Introdução ao investimento anjo"
      # click_on I18n.t('btn.lesson.create')

      # click_on "add-content-Activity"
      # fill_in "media_text", with: "Este é o texto de uma atividade exemplo"
      # click_on "submit-media-content"

      # current_path.should == dashboard_course_lessons_path(@course)
      # page.should have_content "Mídia atualizada com sucesso!"
      # page.should have_content "Visualizar/editar atividade"
    #end

    scenario "Admin da escola tenta adicionar atividade inválida à aula" #, js: true do
      # pending "Faltar descobrir como preencher um campo com tinymce"
      # click_on "new-media-#{@lesson.id}"
      # fill_in "media_title", with: "Introdução ao investimento anjo"
      # click_on I18n.t('btn.lesson.create')

      # click_on "add-content-Activity"
      # fill_in "media_text", with: "Este"
      # click_on "submit-media-content"

      # current_path.should == dashboard_course_lessons_path(@course)
      # page.should have_content "Texto é muito curto (mínimo: 15 caracteres)"
    # end

    scenario "Admin da escola tenta adicionar aula com nome inválido", js: true do
      click_on "new-media-#{@lesson.id}"
      fill_in "media_title", with: "Int"
      click_on I18n.t('btn.lesson.create')

      current_path.should == dashboard_course_lessons_path(@course)
      page.should have_content "Título é muito curto (mínimo: 5 caracteres)"
    end

    scenario "Admin da escola remove uma aula", js: true do
      click_on "new-media-#{@lesson.id}"
      fill_in "media_title", with: "Introdução ao investimento anjo"
      click_on I18n.t('btn.lesson.create')
      visit dashboard_course_lessons_path(@course)

      media = Media.find_by_title("Introdução ao investimento anjo")
      click_on "remove-media-#{media.id}"

      current_path.should == dashboard_course_lessons_path(@course)
      page.should have_content "Aula removida com sucesso"
      page.should_not have_content "Introdução ao investimento anjo"
    end

    scenario "Admin da escola associa vídeo à aula"

    scenario "Admin da escola associa atividade à aula"
  end

end