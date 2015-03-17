#coding: utf-8

require 'spec_helper'

feature 'Escola - Configurações - Gerais' do
  background do
    @user = create(:school_admin)
    @school = @user.school
    switch_to_subdomain @school.subdomain
    login_as @user
    visit configurations_general_dashboard_schools_path
  end

  context "Meios de Pagamento" do
    scenario "Dono da escola atualiza meios de pagamento" do
      uncheck "school_accept_credit_card"
      click_on "Salvar"
      @school.reload

      current_path.should == configurations_general_dashboard_schools_path
      page.should have_content "Configurações gerais atualizadas com sucesso."
      @school.accept_credit_card.should be_false
    end

    scenario "Dono da escola desmarca todos os meios de pagamento" do
      uncheck "school_accept_credit_card"
      uncheck "school_accept_online_debit"
      uncheck "school_accept_billet"
      click_on "Salvar"

      page.should have_content "Sua escola deve aceitar ao menos um meio de pagamento"
    end

    scenario "Aluno não vê meio de pagamento" do
      uncheck "school_accept_online_debit"
      click_on "Salvar"

      @moip = MyMoip::PaymentRequest.any_instance
      MyMoip::TransparentRequest.any_instance.stub api_call: true
      MyMoip::TransparentRequest.any_instance.stub token: "S220W1Q3R0A5L0D2X1I3R5Q1B0I5H8Q8B9V0B030S010L0A3V8A4F5N397O1"

      School.current_id = @school.id
      @course = create(:course)
      visit add_to_cart_course_path(@course)
      @user = create(:student)
      login_as(@user)
      click_on "checkout"
      fill_register_form
      click_on "prosseguir"

      current_path.should == payment_checkouts_path
      page.should_not have_content "Débito Online"
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