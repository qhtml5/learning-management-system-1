# encoding: utf-8

require 'spec_helper'

describe CheckoutsController do
  let(:school_admin) { FactoryGirl.create(:school_admin) }
  let(:school) { school_admin.school }
  let(:user) { FactoryGirl.create(:user) }
  let(:cart) { Cart.create }

  before(:each) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    cart.courses = school.courses
    cart.save!
    session[:cart_id] = cart.id
    MyMoip::PaymentRequest.any_instance.stub api_call: true
    controller.request.stub subdomain: school.subdomain
  end

  describe "GET cart" do
    it "renders the 'cart' page" do
      get :cart
      response.should render_template :cart
    end
  end

  describe "GET social" do
    it "redirects to 'register' page if user is signed in" do
      sign_in(user)
      get :social
      response.should redirect_to register_checkouts_path
    end

    it "redirects to root if cart is not defined" do
      session[:cart_id] = nil
      get :social
      response.should redirect_to root_path(subdomain: school.subdomain)
    end

    it "renders the 'social' page" do
      get :social
      response.should render_template :social
    end
  end

  describe "GET register" do
    before(:each) do
      sign_in(user)
    end

    it "redirects to root if cart is not defined" do
      session[:cart_id] = nil
      get :register
      response.should redirect_to root_path(subdomain: school.subdomain)
    end

    it "renders the 'register' page" do
      get :register
      response.should render_template :register
    end
  end

  describe "GET payment" do
    before(:each) do
      sign_in(user)
    end

    context "params[:purchase_id]" do
      before(:each) do
        @purchase = FactoryGirl.create(:purchase, user: user)
      end

      it 'assigns @purchase' do
        get :payment, purchase_id: @purchase.id
        assigns(:purchase).should == @purchase
      end

      it 'should assign @installments' do
        get :payment, purchase_id: @purchase.id
        assigns(:installments).should == @purchase.maximum_installments
      end

      it "renders the 'payment' page" do
        get :payment, purchase_id: @purchase.id
        response.should render_template :payment
      end    
    end

    context "current_cart" do
      before(:each) do
        @cart = create(:cart, token: "abcDEF123")
        controller.stub current_cart: @cart
      end
      
      it 'assigns cart if purchase_id parameter doesnt exist' do
        get :payment
        assigns(:cart).should == @cart
      end

      it "renders the 'payment' page" do
        get :payment
        response.should render_template :payment
      end    

      it 'should assign @installments' do
        get :payment
        assigns(:installments).should == @cart.maximum_installments
      end
    end

    context "last_purchase" do
      before(:each) do
        @purchase = FactoryGirl.create(:purchase, user: user)
      end

      it 'assigns @purchase' do
        get :payment
        assigns(:purchase).should == @purchase
      end

      it "renders the 'payment' page" do
        get :payment
        response.should render_template :payment
      end    

      it 'should assign @installments' do
        get :payment
        assigns(:installments).should == @purchase.maximum_installments
      end
    end

    context "neither params[:purchase_id] nor current_cart" do
      it "redirects to root" do
        get :payment
        flash[:alert].should == I18n.t("messages.checkout_moip.failure")
        response.should redirect_to root_path(subdomain: school.subdomain)
      end
    end
  end

  describe "GET finish" do
    before(:each) do
      user.purchases = [FactoryGirl.create(:purchase, user: user)]
      user.save!
      sign_in(user)
    end

    let(:message) { "Test message" }

    it "renders the 'finish' page" do
      get :finish, message: message
      response.should render_template :finish
    end    

    it "assigns the message param to @message" do
      get :finish, message: message
      assigns(:message).should eq(message)
    end

    it "assigns the last user purchase to @purchase" do
      user.purchases = [FactoryGirl.create(:purchase, user: user), FactoryGirl.create(:purchase, user: user)]
      user.save!
      purchase = user.purchases.last
      get :finish, message: message
      assigns(:purchase).should eq(purchase)
    end

    it "assigns the courses from the last user purchase to @courses" do
      user.purchases = [FactoryGirl.create(:purchase, user: user), FactoryGirl.create(:purchase, user: user)]
      user.save!
      courses = user.purchases.last.courses
      get :finish, message: message
      assigns(:courses).should eq(courses)      
    end
  end

  describe "GET finish_coupon" do
    before(:each) do
      user.purchases = [FactoryGirl.create(:purchase, user: user)]
      user.save!
      sign_in(user)
    end  

    it "renders the 'finish_coupon' page" do
      get :finish_coupon
      response.should render_template :finish_coupon
    end    

    it "assigns the last user purchase to @purchase" do
      user.purchases = [FactoryGirl.create(:purchase, user: user), FactoryGirl.create(:purchase, user: user)]
      user.save!
      get :finish_coupon
      assigns(:purchase).should == user.purchases.last
    end
  end

  describe "GET failure" do
    let(:message) { "Test message" }

    before(:each) do
      user.purchases = [FactoryGirl.create(:purchase, user: user)]
      user.save!      
      sign_in(user)
    end

    it "renders the 'failure' page" do
      get :failure, message: message
      response.should render_template :failure
    end    

    it "assigns the message param to @message" do
      get :failure, message: message
      assigns(:message).should eq(message)
    end    
  end  

  describe "POST to pay_credit_card" do
    before(:each) do
      sign_in(user)
      user.purchases = [FactoryGirl.create(:purchase, user: user)]
      user.save!      
    end

    let(:purchase) { user.purchases.last }

    let(:payment) do
      {
        credit_card: "Mastercard",
        credit_card_number: "1234123412341234",
        expiration_month: "12",
        expiration_year: "17",
        credit_card_security_code: "551",
        installments: "6"
      }
    end

    let(:moip_response) do
      { 
        "Codigo"=>0, 
        "CodigoRetorno"=>"", 
        "TaxaMoIP"=>"7.05", 
        "StatusPagamento"=>"Sucesso", 
        "CodigoMoIP"=>146444, 
        "Mensagem"=>"Requisição processada com sucesso", 
        "TotalPago"=>"90.00"
      }
    end

    context "valid credit card" do
      context "request success" do
        before(:each) do
          moip_response["Status"] = "EmAnalise"
          MyMoip::PaymentRequest.any_instance.stub(:success?).and_return(true)
          MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)
        end

        it "should send purchase pending notification to user" do
          Notification.should_receive(:create).with do |*args|
            notification = args.pop
            notification[:receiver].should == purchase.user
            notification[:code].should == Notification::PURCHASE_USER_PENDING
            notification[:notifiable].should == purchase
            true
          end
          Notification.stub(create_list: true)
          post :pay_credit_card, payment: payment, purchase_id: purchase.id
        end

        it "should send purchase liberated notification to user if automatic liberation is active" do
          school.automatic_confirmation = true
          school.save!
          Notification.should_receive(:create).with do |*args|
            notification = args.pop
            notification[:receiver].should == purchase.user
            notification[:code].should == Notification::PURCHASE_USER_LIBERATED
            notification[:notifiable].should == purchase
            true
          end
          Notification.stub(create_list: true)
          post :pay_credit_card, payment: payment, purchase_id: purchase.id
        end

        it "should send purchase pending notification to school team" do
          Notification.should_receive(:create_list).with do |*args|
            notification = args.pop
            notification[:sender].should == purchase.user
            notification[:receivers].should == purchase.school.admins + purchase.teachers
            notification[:code].should == Notification::PURCHASE_PENDING
            notification[:notifiable].should == purchase
            true
          end
          Notification.stub(create: true)
          post :pay_credit_card, payment: payment, purchase_id: purchase.id
        end

        it "should send purchase liberated notification to school team if automatic liberation is on" do
          school.automatic_confirmation = true
          school.save!
          Notification.should_receive(:create_list).with do |*args|
            notification = args.pop
            notification[:sender].should == purchase.user
            notification[:receivers].should == purchase.school.admins + purchase.teachers
            notification[:code].should == Notification::PURCHASE_LIBERATED
            notification[:notifiable].should == purchase
            true
          end
          Notification.stub(create: true)
          post :pay_credit_card, payment: payment, purchase_id: purchase.id
        end

        it "should redirect to finish page" do
          post :pay_credit_card, payment: payment, purchase_id: purchase.id
          response.should redirect_to finish_checkouts_path
        end

        it "should update purchase attributes" do
          post :pay_credit_card, payment: payment, purchase_id: purchase.id
          purchase.reload
          purchase.payment_status.should == "EmAnalise"
          purchase.payment_type.should == "CartaoCredito"
          purchase.moip_tax.should == 7.05
          purchase.amount_paid.should == 9000.00
          purchase.moip_code.should == 146444
        end

        it "should set payment_status to 'Liberado' if school automatic confirmation is active" do
          school.automatic_confirmation = true
          school.save!
          post :pay_credit_card, payment: payment, purchase_id: purchase.id
          purchase.reload
          purchase.payment_status.should == "Liberado"
        end
      end

      context "request fail (status = 'Cancelado')" do
        it "should set flash message and redirect to failure page" do
          moip_response["Status"] = "Cancelado"
          MyMoip::PaymentRequest.any_instance.stub(:success?).and_return(false)
          MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)

          post :pay_credit_card, payment: payment, purchase_id: purchase.id

          flash[:purchase_message].should == "Cartão de crédito inválido"
          response.should redirect_to failure_checkouts_path
        end
      end

      context "request fail (status = 'Falha')" do
        it "should set flash message and redirect to failure page" do
          moip_response["Status"] = "Falha"
          moip_response["Mensagem"] = "Token inválido"
          MyMoip::PaymentRequest.any_instance.stub(:success?).and_return(false)
          MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)

          post :pay_credit_card, payment: payment, purchase_id: purchase.id

          flash[:purchase_message].should == "Token inválido"
          response.should redirect_to failure_checkouts_path
        end
      end
    end

    context "invalid credit card" do
      it "should set flash message and redirect to failure page" do
        payment[:credit_card] = ""
        MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)

        post :pay_credit_card, payment: payment, purchase_id: purchase.id
        flash[:purchase_message].should == "Cartão de crédito inválido"
        response.should redirect_to failure_checkouts_path
      end
    end
  end

  describe "POST to pay_online_debit" do
    before(:each) do
      sign_in(user)
      user.purchases = [FactoryGirl.create(:purchase, user: user)]
      user.save!        
    end

    let(:purchase) { user.purchases.last }
    let(:payment) { { institution: "BancoDoBrasil" } }
    let(:moip_response) do
      {"Codigo"=>0, "StatusPagamento"=>"Sucesso", "Mensagem"=>"Requisição processada com sucesso"}
    end

    def do_action
      post :pay_online_debit, payment: payment, purchase_id: purchase.id
    end

    context "request success" do
      before(:each) do
        MyMoip::PaymentRequest.any_instance.stub(:success?).and_return(true)
        MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)
      end

      it "assigns @purchase" do
        do_action
        assigns(:purchase).should == purchase
      end

      it "should render finish onliny payment" do
        do_action
        response.should redirect_to finish_online_payment_checkouts_path
      end

      it "should update purchase attributes" do
        do_action
        purchase.reload
        purchase.payment_type.should == "DebitoBancario"
      end

      it "should send notification to user" do
        Notification.should_receive(:create).with do |*args|
          notification = args.pop
          notification[:receiver].should == purchase.user
          notification[:code].should == Notification::PURCHASE_USER_PENDING
          notification[:notifiable].should == purchase
          true
        end
        Notification.stub(create_list: true)
        do_action
      end

      it "should send notification to school team" do
        Notification.should_receive(:create_list).with do |*args|
          notification = args.pop
          notification[:sender].should == purchase.user
          notification[:receivers].should == purchase.school.admins + purchase.teachers
          notification[:code].should == Notification::PURCHASE_PENDING
          notification[:notifiable].should == purchase
          true
        end
        Notification.stub(create: true)
        do_action
      end
    end

    context "request fail" do
      before(:each) do
        MyMoip::PaymentRequest.any_instance.stub(:success?).and_return(false)
        MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)
        do_action 
      end

      it { flash[:purchase_message].should == moip_response["Mensagem"] }
      it { response.should redirect_to failure_checkouts_path }
    end
  end

  describe "POST to pay_bilet" do
    before(:each) do
      sign_in(user)
      user.purchases = [FactoryGirl.create(:purchase, user: user)]
      user.save!        
    end

    let(:purchase) { user.purchases.last }
    let(:payment) { { form: "Billet" } }
    let(:moip_response) do
      {"Codigo"=>0, "StatusPagamento"=>"Sucesso", "Mensagem"=>"Requisição processada com sucesso"}
    end

    def do_action
      post :pay_billet, payment: payment, purchase_id: purchase.id
    end

    context "request success" do
      before(:each) do
        MyMoip::PaymentRequest.any_instance.stub(:success?).and_return(true)
        MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)
      end

      it { do_action ; assigns(:purchase).should == purchase }
      it { do_action ; response.should redirect_to finish_online_payment_checkouts_path }

      it "should update purchase attributes" do
        do_action
        purchase.reload
        purchase.payment_type.should == "BoletoBancario"
      end

      it "should send notification to user" do
        Notification.should_receive(:create).with do |*args|
          notification = args.pop
          notification[:receiver].should == purchase.user
          notification[:code].should == Notification::PURCHASE_USER_PENDING
          notification[:notifiable].should == purchase
          true
        end
        Notification.stub(create_list: true)
        do_action
      end

      it "should send notification to school team" do
        Notification.should_receive(:create_list).with do |*args|
          notification = args.pop
          notification[:sender].should == purchase.user
          notification[:receivers].should == purchase.school.admins + purchase.teachers
          notification[:code].should == Notification::PURCHASE_PENDING
          notification[:notifiable].should == purchase
          true
        end
        Notification.stub(create: true)
        do_action
      end
    end

    context "request fail" do
      before(:each) do
        MyMoip::PaymentRequest.any_instance.stub(:success?).and_return(false)
        MyMoip::PaymentRequest.any_instance.stub(:response).and_return(moip_response)
        do_action 
      end

      it { flash[:purchase_message].should == moip_response["Mensagem"] }
      it { response.should redirect_to failure_checkouts_path }
    end
  end  

end

