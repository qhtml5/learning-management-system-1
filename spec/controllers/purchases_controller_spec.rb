# encoding: utf-8

require 'spec_helper'

describe PurchasesController do
  let(:school_admin) { FactoryGirl.create(:school_admin) }
  let(:school) { school_admin.school }
  before(:each) { School.current_id = school.id }
  let(:purchase) { create(:purchase) }
  
  describe "POST notification" do
    context "completed purchase" do
      let(:params) do
        {
          "id_transacao" => purchase.identificator,
          "status_pagamento" => "4",
          "cod_moip" => 137649,
          "valor" => 101.0,
          "tipo_pagamento" => "CartaoCredito"
        }
      end

      it "should update purchase payment status to 'Concluido'" do
        post :notification, params
        purchase.reload
        purchase.payment_status.should == Purchase::CONFIRMED
      end

      it "should not send email to user" do
        post :notification, params
        ActionMailer::Base.deliveries.should == []
      end

      it "should not create notification" do
        post :notification, params
        Notification.should_not_receive(:create)
      end
    end

    context "authorized purchase" do
      let(:params) do
        {
          "id_transacao" => purchase.identificator,
          "status_pagamento" => "1",
          "cod_moip" => 137649,
          "valor" => 101.0,
          "tipo_pagamento" => "CartaoCredito"
        }
      end

      it "should register user on rdstation as confirmed" do
        course = purchase.courses.first
        Purchase.any_instance.should_receive(:register_on_rdstation).with("confirmado")
        post :notification, params
      end

      it "should send notification to user" do
        Notification.stub create_list: true
        Notification.should_receive(:create).with do |*args|
          notification = args.pop
          notification[:receiver].should == purchase.user
          notification[:code].should == Notification::PURCHASE_USER_CONFIRMED
          notification[:notifiable].should == purchase
          true
        end
        post :notification, params
      end

      it "should send notification to school team" do
        Notification.stub create: true
        Notification.should_receive(:create_list).with do |*args|
          notification = args.pop
          notification[:sender].should == purchase.user
          notification[:receivers].should == purchase.school.admins + purchase.teachers
          notification[:code].should == Notification::PURCHASE_CONFIRMED
          notification[:notifiable].should == purchase
          true
        end
        post :notification, params
      end

      it "should save validity date" do
        Purchase.any_instance.should_receive(:save_validity_date)
        post :notification, params
      end
    end

  end

end

