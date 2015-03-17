#coding: utf-8

class CheckoutsController < ApplicationController
	before_filter :authenticate_user!, except: [:cart, :social]
	load_and_authorize_resource class: :checkout
	
	include Apotomo::Rails::ControllerMethods	
  has_widgets do |root|
    root << widget(:secure_info)
    root << widget(:school_phone_email)
    root << widget(:school_payment_forms)
  end
	
	def cart
	end

	def social
		if current_cart
			@user = User.new
			redirect_to :action => :register if user_signed_in?
		else
			redirect_to root_path(subdomain: current_school.subdomain)
		end
	end

	def register
		if current_cart || params[:purchase_id]
			@user = current_user
			@user.build_address if @user.address.nil?
		else
			redirect_to root_path(subdomain: current_school.subdomain)
		end
	end

	def payment
		if params[:purchase_id]
			@purchase = Purchase.find_by_id(params[:purchase_id])
			@installments = @purchase.maximum_installments
		elsif current_cart.present? && current_cart.token.present?
			@cart = current_cart
			@installments = @cart.maximum_installments
		elsif current_user.purchases.any?
			@purchase = current_user.purchases.last
			@installments = @purchase.maximum_installments
		else
			flash[:alert] = I18n.t("messages.checkout_moip.failure")
			redirect_to root_path(subdomain: current_school.subdomain) and return
		end
	end

	def failure
		@message = params[:message]
	end

	def finish
		@purchase = current_user.purchases.last
		
		unless @purchase
			redirect_to root_path(subdomain: current_school.subdomain) 
		end

		@message = params[:message]
		@courses = @purchase.courses
	end

	def finish_online_payment
		@purchase = current_user.purchases.last
		
		unless @purchase
			redirect_to root_path(subdomain: current_school.subdomain) 
		end

		@url = MyMoip.api_url + "/Instrucao.do?token=#{@purchase.token}"
	end

	def finish_coupon
		@purchase = current_user.purchases.last

		unless @purchase
			redirect_to root_path(subdomain: current_school.subdomain) 
		end
	end

	def pay_credit_card	
		find_purchase

		unless @purchase.present? && @token.present?
			flash[:alert] = I18n.t("messages.checkout_moip.failure")
			redirect_to root_path(subdomain: current_school.subdomain) and return
		end

		credit_card = build_credit_card
		
		unless credit_card.valid?
			flash[:purchase_message] = "Cartão de crédito inválido"
			SupportMailer.payment_credit_card_failure(@purchase, credit_card).deliver
			redirect_to failure_checkouts_path and return
		end

		credit_card_payment = MyMoip::CreditCardPayment.new(credit_card, installments: params[:payment][:installments])
		payment_request = MyMoip::PaymentRequest.new("zangrandii@gmail.com")
		payment_request.api_call(credit_card_payment, token: @token)

		unless payment_request.response["Status"] != "Cancelado"
			flash[:purchase_message] = "Cartão de crédito inválido"
			redirect_to failure_checkouts_path and return
		end
		
		unless payment_request.success?
			flash[:purchase_message] = payment_request.response["Mensagem"]
			redirect_to failure_checkouts_path and return
		end

		payment_request.response["Forma"] = "CartaoCredito"
		update_purchase_attributes(payment_request.response)

		if current_school.automatic_confirmation
			@purchase.payment_status = Purchase::LIBERATED
		end

		if @purchase.save
			session[:cart_id] = nil if current_cart && session[:cart_id] == current_cart.id
			current_cart.destroy if current_cart
			if current_school.automatic_confirmation
				@purchase.register_on_rdstation "liberado"
				@purchase.create_liberated_notification
			else
				@purchase.register_on_rdstation "pendente"
				@purchase.create_pending_notification
			end
			redirect_to finish_checkouts_path
		else
			flash[:purchase_message] = "Erro ao gerar compra"
			redirect_to failure_checkouts_path
		end
	end

	def pay_online_debit
		find_purchase

		unless @purchase.present? && @token.present?
			flash[:alert] = I18n.t("messages.checkout_moip.failure")
			redirect_to root_path(subdomain: current_school.subdomain) and return
		end

		online_payment = OnlinePayment.new("DebitoBancario", institution: params[:payment][:institution])

		payment_request = MyMoip::PaymentRequest.new("zangrandii@gmail.com")
		payment_request.api_call(online_payment, token: @token)

		# payment_request.response["StatusPagamento"] = "Falha"
		
		unless payment_request.success?
			flash[:purchase_message] = payment_request.response["Mensagem"]
			redirect_to failure_checkouts_path and return
		end

		payment_request.response["Forma"] = "DebitoBancario"
		update_purchase_attributes(payment_request.response)

		if @purchase.save
			session[:cart_id] = nil if current_cart && session[:cart_id] == current_cart.id
			current_cart.destroy if current_cart
			@purchase.register_on_rdstation "pendente"
			@purchase.create_pending_notification
			redirect_to finish_online_payment_checkouts_path
		else
			flash[:purchase_message] = "Erro ao gerar compra"
			redirect_to failure_checkouts_path
		end
	end

	def pay_billet
		find_purchase

		unless @purchase.present? && @token.present?
			flash[:alert] = I18n.t("messages.checkout_moip.failure")
			redirect_to root_path(subdomain: current_school.subdomain) and return
		end

		online_payment = OnlinePayment.new("BoletoBancario")
		payment_request = MyMoip::PaymentRequest.new("zangrandii@gmail.com")
		payment_request.api_call(online_payment, token: @token)

		unless payment_request.success?
			flash[:purchase_message] = payment_request.response["Mensagem"]
			redirect_to failure_checkouts_path and return
		end

		payment_request.response["Forma"] = "BoletoBancario"
		update_purchase_attributes(payment_request.response)

		if @purchase.save
			session[:cart_id] = nil if current_cart && session[:cart_id] == current_cart.id
			current_cart.destroy if current_cart
			@purchase.register_on_rdstation "pendente"
			@purchase.create_pending_notification
			redirect_to finish_online_payment_checkouts_path
		else
			flash[:purchase_message] = "Erro ao gerar compra"
			redirect_to failure_checkouts_path
		end
	end	

	private
	def update_purchase_attributes response
		@purchase.payment_status = response["Status"] if response["Status"].present?
		@purchase.payment_type = response["Forma"] if response["Forma"].present?
		@purchase.moip_tax = response["TaxaMoIP"] if response["TaxaMoIP"].present?
		@purchase.moip_code = response["CodigoMoIP"] if response["CodigoMoIP"].present?
		if Rails.env.production? && response["TotalPago"].present?
			@purchase.amount_paid = response["TotalPago"]
		elsif response["TotalPago"].present?
			@purchase.amount_paid = (response["TotalPago"].to_f * 100).to_i
		end
	end

	def find_purchase
		if params[:purchase_id]
			@purchase = Purchase.find_by_id(params[:purchase_id])
			@token = @purchase.token
		elsif current_cart.present? && current_cart.token.present?
			@purchase = current_user.purchases.build(
				cart_items: current_cart.cart_items,
	      identificator: current_cart.identificator,
	      token: current_cart.token,
	      payment_status: "Iniciado"
			)
			@token = current_cart.token
		elsif current_user.purchases.any?
			@purchase = current_user.purchases.last
			@token = @purchase.token
		end
	end

	def build_credit_card
		MyMoip::CreditCard.new(
		  logo: params[:payment][:credit_card].try(:downcase),
		  card_number: params[:payment][:credit_card_number],
		  expiration_date: "#{params[:payment][:expiration_month]}/#{params[:payment][:expiration_year]}",
		  security_code: params[:payment][:credit_card_security_code],
		  owner_name: current_user.full_name,
		  owner_birthday: "03/11/1984",
		  owner_phone: current_user.phone_number,
		  owner_cpf: current_user.cpf.to_s
		)
	end

	def use_https?
		if current_school.try(:use_custom_domain)
		  ["pay_credit_card", "payment", "pay_online_debit", "pay_billet"].include?(params[:action])
		else
			!request.host.include?("lvh.me") && !Rails.env.staging?
		end
  end
end