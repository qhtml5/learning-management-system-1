#coding: utf-8

require 'spec_helper'

feature 'Checkout Pagamento' do
	background do
		@moip = MyMoip::PaymentRequest.any_instance
		MyMoip::TransparentRequest.any_instance.stub api_call: true
		MyMoip::TransparentRequest.any_instance.stub token: "S220W1Q3R0A5L0D2X1I3R5Q1B0I5H8Q8B9V0B030S010L0A3V8A4F5N397O1"

		@school_admin = create(:school_admin)
    @school = @school_admin.school
    School.current_id = @school.id
    @course = create(:course)
    switch_to_subdomain @school.subdomain
		visit add_to_cart_course_path(@course)
		@user = create(:student)
		login_as(@user)
		click_on "checkout"
		fill_register_form
		click_on "prosseguir"
	end

	context "Pagamento com Cartão de crédito" do
		background do 
			@payment_return = {
				"Status"=>"EmAnalise", 
				"Codigo"=>0, 
				"CodigoRetorno"=>"", 
				"TaxaMoIP"=>"22.59", 
				"StatusPagamento"=>"Sucesso", 
				"CodigoMoIP"=>139117, 
				"Mensagem"=>"Requisição processada com sucesso", 
				"TotalPago"=>"300.00"
			}
		end

		scenario "Aluno efetua pagamento por cartão de crédito" do
			choose "payment_credit_card_Mastercard"
			fill_in "payment_credit_card_number", :with => "1234123412341234"
			fill_in "payment_credit_card_security_code", :with => "123"
			select "01", :from => "payment_expiration_month"
			select "15", :from => "payment_expiration_year"

			@moip.stub(api_call: true, success?: true, response: @payment_return)

			click_on "comprar-curso-cartao-credito"

			within(".navbar") do
				page.should_not have_content "Carrinho"
			end

			current_path.should == finish_checkouts_path
			@purchase = Purchase.last
			@purchase.payment_status.should == @payment_return["Status"]
			@purchase.moip_code.should == @payment_return["CodigoMoIP"]
			@purchase.token.should == "S220W1Q3R0A5L0D2X1I3R5Q1B0I5H8Q8B9V0B030S010L0A3V8A4F5N397O1"
			page.should have_content @purchase.payment_status
			page.should have_content @purchase.moip_code
			@purchase.courses.each do |course|
				page.should have_content course.pitch
			end
		end

		scenario "Aluno efetua pagamento parcelado"

		scenario "Aluno tenta efetuar pagamento com cartão de crédito inválido" do
			choose "payment_credit_card_Mastercard"
			fill_in "payment_credit_card_number", :with => "12341234"
			fill_in "payment_credit_card_security_code", :with => "12"
			select "01", :from => "payment_expiration_month"
			select "15", :from => "payment_expiration_year"

			click_on "comprar-curso-cartao-credito"

			current_path.should == failure_checkouts_path
			page.should have_content "Cartão de crédito inválido"
		end

		scenario "Aluno tenta efetuar pagamento com cartão de crédito e o pagamento é cancelado pelo Moip" do
			@payment_return["Status"] = "Cancelado"

			choose "payment_credit_card_Mastercard"
			fill_in "payment_credit_card_number", :with => "1234123412341234"
			fill_in "payment_credit_card_security_code", :with => "123"
			select "01", :from => "payment_expiration_month"
			select "15", :from => "payment_expiration_year"

			@moip.stub(api_call: true, success?: true, response: @payment_return)

			click_on "comprar-curso-cartao-credito"

			current_path.should == failure_checkouts_path
			page.should have_content "Cartão de crédito inválido"
		end	

		scenario "Aluno tenta efetuar pagamento e ocorre alguma falha no pagamento" do
			@payment_return["Status"] = "Falha"

			choose "payment_credit_card_Mastercard"
			fill_in "payment_credit_card_number", :with => "1234123412341234"
			fill_in "payment_credit_card_security_code", :with => "123"
			select "01", :from => "payment_expiration_month"
			select "15", :from => "payment_expiration_year"

			@moip.stub(api_call: true, response: @payment_return)		

			click_on "comprar-curso-cartao-credito"

			current_path.should == failure_checkouts_path
			page.should have_content @payment_return["Mensagem"]
		end

		scenario "Aluno tenta efetuar pagamento e ocorre erro ao gerar compra" do
			choose "payment_credit_card_Mastercard"
			fill_in "payment_credit_card_number", :with => "1234123412341234"
			fill_in "payment_credit_card_security_code", :with => "123"
			select "01", :from => "payment_expiration_month"
			select "15", :from => "payment_expiration_year"

			@moip.stub(api_call: true, success?: true, response: @payment_return)
			Purchase.any_instance.stub(save: false)

			click_on "comprar-curso-cartao-credito"

			current_path.should == failure_checkouts_path
			page.should have_content "Erro ao gerar compra"
		end
	end

	context "Pagamento por Debito online" do
		background do
			@payment_return = {
				"Codigo"=>0, 
				"StatusPagamento"=>"Sucesso", 
				"Mensagem"=>"Requisição processada com sucesso"
			}
		end

		scenario "Aluno efetua pagamento por débito online" do
			click_on "Débito Online"
			choose "payment_institution_BancoDoBrasil"

			@moip.stub(api_call: true, success?: true, response: @payment_return)

			click_on "comprar-curso-debito-online"

			current_path.should == finish_online_payment_checkouts_path
			@purchase = Purchase.last
			page.should have_link("clique aqui", href: MyMoip.api_url + "/Instrucao.do?token=#{@purchase.token}")
			@purchase.courses.each do |course|
				page.should have_content course.pitch
			end
		end

		scenario "Aluno efetua pagamento por débito online mas ocorre erro ao gerar compra" do
			click_on "Débito Online"
			choose "payment_institution_BancoDoBrasil"

			@moip.stub(api_call: true, success?: true, response: @payment_return)
			Purchase.any_instance.stub(save: false)

			click_on "comprar-curso-debito-online"

			current_path.should == failure_checkouts_path
			page.should have_content "Erro ao gerar compra"
		end		
	end

	context "Pagamento por Boleto" do
		background do
			@payment_return = {
				"Codigo"=>0, 
				"StatusPagamento"=>"Sucesso", 
				"Mensagem"=>"Requisição processada com sucesso"
			}
		end

		scenario "Aluno efetua pagamento por boleto" do
			click_on "Boleto Bancário"

			@moip.stub(api_call: true, success?: true, response: @payment_return)

			click_on "comprar-curso-boleto-bancario"

			current_path.should == finish_online_payment_checkouts_path
			@purchase = Purchase.last
			page.should have_link("clique aqui", href: MyMoip.api_url + "/Instrucao.do?token=#{@purchase.token}")
			@purchase.courses.each do |course|
				page.should have_content course.pitch
			end
		end

		scenario "Aluno efetua pagamento por boleto mas ocorre erro ao gerar compra" do
			click_on "Boleto Bancário"

			@moip.stub(api_call: true, success?: true, response: @payment_return)
			Purchase.any_instance.stub(save: false)

			click_on "comprar-curso-boleto-bancario"

			current_path.should == failure_checkouts_path
			page.should have_content "Erro ao gerar compra"
		end		
	end
end

def fill_register_form
	fill_in_inputmask :user_phone_number, :with => "2298992600"
	fill_in_inputmask :user_cpf, :with => "13865809707"
	fill_in :user_address_attributes_street, :with => "Rua 20"
	fill_in :user_address_attributes_number, :with => "200"
	fill_in :user_address_attributes_district, :with => "Bairro"
	fill_in :user_address_attributes_city, :with => "Cidade"
	select "RJ", :from => :user_address_attributes_state
	fill_in_inputmask :user_address_attributes_zip_code, :with => "24800000"
end