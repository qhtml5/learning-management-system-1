#coding: utf-8

require 'spec_helper'

feature 'Checkout Registro' do
	background do
    @school = create(:school)
    School.current_id = @school.id
    @course = create(:course)
    @user = create(:user)
    login_as(@user)
    switch_to_subdomain @school.subdomain    
		visit add_to_cart_course_path(@course)
	end

	scenario "Aluno completa o registro" do
		click_on "checkout"
		fill_register_form

		MyMoip::TransparentRequest.any_instance.should_receive(:api_call).and_return(true)
		MyMoip::TransparentRequest.any_instance.should_receive(:token).twice.and_return("123456")

		click_on "prosseguir"

		@user = User.last
		current_path.should == payment_checkouts_path
		# page.find_field("payment_name").value.should == @user.full_name
		# page.find_field("payment_phone_number").value.should == "2298992600"
		# page.find_field("payment_cpf").value.should == @user.cpf.to_s
		page.should have_content "Cadastro completo com sucesso, efetue o pagamento"
	end

	scenario "Aluno completa o registro em uma compra com cupom com 100% de desconto" do
		@coupon = create(:coupon, course: @course, discount: 100)
		fill_in "cart-coupon-course-#{@course.id}", with: @coupon.name
		click_on "refresh-coupon-#{@course.id}"
		click_on "checkout"
		fill_register_form
		click_on "prosseguir"

		current_path.should == finish_coupon_checkouts_path
		page.should have_content @course.title
	end

	scenario "Aluno preenche o registro errado" do
		click_on "checkout"
		fill_register_form
		fill_in :user_phone_number, :with => ""

		click_on "prosseguir"		

		current_path.should == user_registration_path

		within(".user_phone_number.error") do
			page.should have_content "é muito curto (mínimo: 10 caracteres)"
		end
	end

	scenario "Aluno completa o registro mas ocorre uma exceção" do
		click_on "checkout"
		fill_register_form

		MyMoip::TransparentRequest.any_instance.stub(:api_call).and_raise

		click_on "prosseguir"

		current_path.should == exception_checkouts_path(subdomain: @school.subdomain)
	end

	scenario "Aluno completa o registro mas ocorre um erro de comunicação" do
		click_on "checkout"
		fill_register_form

		MyMoip::TransparentRequest.any_instance.should_receive(:api_call).and_return(false)
		MyMoip::TransparentRequest.any_instance.stub(token: nil)

		click_on "prosseguir"

		current_path.should == exception_checkouts_path(subdomain: @school.subdomain)
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
