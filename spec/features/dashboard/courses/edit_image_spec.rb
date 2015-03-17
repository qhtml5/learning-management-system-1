#coding: utf-8

require 'spec_helper'

feature 'Edição de Imagem' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
    login_as @user
    visit edit_image_dashboard_course_path(@course)
  end

  scenario "Usuário edita imagem do curso" do
    attach_file "course_logo", File.expand_path("#{Rails.root}/spec/support/data/logo-startupbase.png", __FILE__)
    click_on "Salvar"
    @course.reload
    page.should have_content "Curso atualizado com sucesso"
    current_path.should == edit_image_dashboard_course_path(@course)
    @course.logo.class.should == Paperclip::Attachment
  end

  scenario "Usuário tenta subir arquivo que não é uma imagem" do
    attach_file "course_logo", File.expand_path("#{Rails.root}/spec/support/data/logo-startupbase.xls", __FILE__)
    click_on "Salvar"
    page.should have_content "Arquivo inválido (permitido apenas jpeg/png/gif)"
  end
end