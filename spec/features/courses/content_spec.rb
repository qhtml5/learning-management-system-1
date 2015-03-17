#coding: utf-8

require 'spec_helper'

feature 'Conteúdo' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    School.current_id = @school.id
	end

  context "Dono de escola" do
    background do
      login_as @user
      visit content_course_path(@course)
    end

    scenario "Usuário submete uma resposta", js: true do
      fill_in "message_text", with: "Enviando uma pergunta de teste"
      click_on "ask-btn"    

      sleep(1)

      fill_in "answer_text", with: "Enviando uma resposta de teste"
      click_on "answer-btn"

      sleep(1)

      page.find('.message').trigger(:mouseover)

      page.should have_content "Resposta enviada com sucesso"
      within("#questions") do
        page.should have_content @user.first_name
        page.should have_content "Enviando uma pergunta de teste"
        page.should have_content "1 resposta"
        page.should have_content "Enviando uma resposta de teste"
      end
    end

    scenario "Usuário apaga uma pergunta", js: true do
      fill_in "message_text", with: "Enviando uma pergunta de teste"
      click_on "Enviar"  
      
      sleep(1)

      click_on "destroy_message_#{Message.last.id}"

      sleep(1)

      page.should have_content "Mensagem removida com sucesso"  
      page.should_not have_content "Enviando uma pergunta de teste"
    end
  end
  
  context "Aluno" do
    background do
      @student = create(:student)
      @cart_items = @school.courses.inject([]) { |r, course| r << create(:cart_item, course: course) }
      create(:purchase_confirmed, user: @student, cart_items: @cart_items)
      login_as @student
      visit content_course_path(@course)
    end

    scenario "Usuário vê a ementa do curso" do
      page.should have_content @course.title
      within("#curriculum") do
        @course.lessons.each do |lesson|
          page.should have_content lesson.title

          lesson.medias.each do |media|
            page.should have_content media.title
          end
        end
      end
    end

    scenario "Usuário visualiza mídia" do
      @media = @course.medias.last
      Wistia::Media.stub find: Wistia::Media.new(embedCode: "conteudo_embed_code_wistia")

      visit course_media_path(@course, @media)

      page.should have_content @media.title
      page.should have_selector "#wistia_#{@media.wistia_hashed_id}"
    end

    scenario "Usuário tenta visualizar mídia mas o wistia falha" do
      @media = @course.medias.last
      Wistia::Media.stub(:find).and_raise("error")

      visit course_media_path(@course, @media)

      page.should have_content "Ocorreu um erro ao o renderizar conteúdo. Tente novamente mais tarde."
      current_path.should == content_course_path(@course)
    end

    scenario "Usuário submete uma pergunta", js: true do
      fill_in "message_text", with: "Enviando uma pergunta de teste"

      click_on "Enviar"

      sleep(1)

      @course.reload
      @message = @course.messages.last

      current_path.should == content_course_path(@course)
      within("#questions") do
        page.should have_content "Pergunta enviada com sucesso"
        page.should have_content @user.first_name
        page.should have_content @message.text
      end
    end
    scenario "Aluno solicita certificado para curso que o oferece" do
      @course.update_attribute :certificate_available, true
      visit content_course_path(@course)

      Notification.should_receive(:create_list).exactly(1).times

      click_on "request-certificate"

      current_path.should == content_course_path(@course)
      page.should have_content "Solicitação de certificado enviada com sucesso"
    end

    scenario "Aluno não vê botão de solicitar certificado para curso que não o oferece" do
      page.should_not have_link "request-certificate"
    end

    scenario "Aluno tenta solicitar certificado mas ocorre um erro" do
      @course.update_attribute :certificate_available, true
      visit content_course_path(@course)
      
      Notification.stub(:create_list).and_raise
      
      click_on "request-certificate"

      current_path.should == content_course_path(@course)
      page.should have_content "Ocorreu um erro ao solicitar seu certificado"
    end

    scenario "Usuário faz uma avaliação"

    scenario "Usuário edita sua avaliação"
  end
  
end