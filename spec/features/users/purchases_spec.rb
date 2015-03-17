#coding: utf-8

require 'spec_helper'

feature 'Minhas compras' do
	background do
		@school = create(:school)
		School.current_id = @school.id
		@user = create :user
		login_as @user
	end

	scenario "Usuário visualiza suas compras" do
		@purchase = create :purchase, user: @user, payment_type: "CartaoCredito", amount_paid: 399
		@course = @purchase.courses.sample
		
		visit purchases_user_path

		page.should have_content @course.title
		page.should have_content @purchase.created_at.strftime("%d/%m/%Y %H:%M")
		page.should have_content @purchase.id
		page.should have_content @purchase.payment_type
		page.should have_content @purchase.amount_paid.to_i.em_real
	end

	scenario "Usuário visualiza mensagem caso ainda não tenha efetuado compras" do
		visit purchases_user_path
		page.should have_content "Não há dados de compras disponíveis"
	end

	scenario "Usuário não visualiza botão de comprar em uma compra confirmada" do
		@purchase = create :purchase_confirmed, user: @user
		visit purchases_user_path	
		page.should_not have_link("Pagar", payment_checkouts_path(purchase_id: @purchase.id))
	end

	scenario "Usuário visualiza botão de comprar em uma compra não confirmada" do
		@purchase = create :purchase, user: @user
		visit purchases_user_path	
		page.should have_link("Pagar", payment_checkouts_path(purchase_id: @purchase.id))
	end
end
