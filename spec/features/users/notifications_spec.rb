#coding: utf-8

require 'spec_helper'

feature 'Notificações' do
	background do
		@user = create(:school_admin)
		@school = @user.school
		School.current_id = @school.id
		switch_to_subdomain @school.subdomain
		@student = create(:student)
    @course = create(:course)
		create(:notification, receiver: @user,
													sender: @student,
													code: Notification::USER_NEW_REGISTRATION,
													notifiable: @student)
		create(:notification, receiver: @user,
													sender: @student,
													code: Notification::COURSE_ADD_TO_CART,
													notifiable: @course)
		login_as @user
		visit notifications_user_path
	end

  scenario "Usuário vê todas as suas notificações" do
  	page.should have_content "#{@student.full_name} adicionou o curso #{@course.title} ao carrinho."
  	page.should have_content "#{@student.full_name} entrou na escola."
  end

  scenario "Usuário marca todas as notificações como lidas" do
  	click_on "Marcar tudo como lido"
  	page.should have_content "Todas as notificações foram marcadas como lidas"
  	current_path.should == notifications_user_path
  end

end